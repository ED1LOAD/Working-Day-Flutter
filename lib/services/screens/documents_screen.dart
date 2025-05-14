import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:test/services/data/document.dart';
import 'package:test/services/domain/document_service.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/data/user_action.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:test/user/domain/user_preferences.dart';

class DocumentsListScreen extends StatefulWidget {
  const DocumentsListScreen({Key? key}) : super(key: key);

  @override
  DocumentsListScreenState createState() => DocumentsListScreenState();
}

class DocumentsListScreenState extends State<DocumentsListScreen> {
  final DocumentsService documentService = DocumentsService();
  late List<DocumentItem> _documents = [];
  bool _isLoading = true;
  final Map<String, String> _employeeNames = {};
  String? currentUserId;

  bool _hasRejectedChainItem(List<DocumentsChainMetadataItem> chainMetadata) {
    return chainMetadata.any((item) => item.status == 2);
  }

  bool _isChainDocument(DocumentItem document) {
    return document.chainMetadata != null && document.chainMetadata!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _loadCurrentUser();
  }

  String _statusLabel(int status) {
    switch (status) {
      case 0:
        return 'Ожидается';
      case 1:
        return 'Подписано';
      case 2:
        return 'Отклонено';
      default:
        return 'Неизвестно';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await UserPreferences.fetchProfileInfo();
      setState(() {
        currentUserId = user.id;
      });
    } catch (e) {
      print("Ошибка при получении данных текущего пользователя: $e");
    }
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _documents = await documentService.fetchDocuments();

      for (var document in _documents) {
        for (var chainItem in document.chainMetadata ?? []) {
          await _loadEmployeeName(chainItem.employeeId);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки документов: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmployeeName(String employeeId) async {
    if (_employeeNames.containsKey(employeeId)) return;
    try {
      final user = await UserPreferences.fetchUserInfoById(employeeId);
      final fullName =
          '${user.surname} ${user.name} ${user.patronymic ?? ''}'.trim();
      setState(() {
        _employeeNames[employeeId] = fullName;
      });
    } catch (e) {
      print('Не удалось загрузить ФИО сотрудника $employeeId: $e');
    }
  }

  Future<void> _signDocument(String documentId, int index) async {
    var document = _documents[index];

    bool canSign = false;
    for (var chainItem in document.chainMetadata ?? []) {
      if (chainItem.employeeId == currentUserId && chainItem.status == 0) {
        canSign = true;
        break;
      }
    }

    if (!canSign) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Вы не можете подписать этот документ в данный момент')),
      );
      return;
    }

    try {
      await documentService.signDocument(documentId);
      var updatedDocument = _documents[index].copyWith(isSigned: true);
      setState(() {
        _documents[index] = updatedDocument;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Документ успешно подписан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка подписания документа: $e')),
      );
    }
  }

  Future<void> _updateChainStatus(
      String documentId, int chainIndex, int status) async {
    var document = _documents.firstWhere((doc) => doc.id == documentId);
    var chainMetadata = document.chainMetadata!;

    bool canSign = false;
    for (var chainItem in chainMetadata) {
      if (chainItem.employeeId == currentUserId && chainItem.status == 0) {
        canSign = true;
        break;
      }
    }

    if (!canSign) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы не можете подписать этот документ')),
      );
      return;
    }

    int approvalStatus;
    if (status == 1) {
      approvalStatus = 1;
    } else if (status == 2) {
      approvalStatus = 2;
    } else {
      approvalStatus = 0;
    }

    DocumentsChainUpdateItem updatedItem = DocumentsChainUpdateItem(
      employeeId: currentUserId!,
      requiresSignature: chainMetadata[chainIndex].requiresSignature,
      approvalStatus: approvalStatus,
    );

    try {
      await documentService.updateDocumentSignChain(
          documentId, updatedItem.approvalStatus);

      setState(() {
        chainMetadata[chainIndex].status = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Статус обновлен')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления статуса: $e')),
      );
    }
  }

  Future<File> _downloadFile(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Exception('Received empty file');
      }
      var dir = await getApplicationDocumentsDirectory();
      File file =
          File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  void openPDF(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DocumentViewPage(file: file)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Список документов',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];

                bool hasRejected =
                    _hasRejectedChainItem(document.chainMetadata!);

                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      collapsedBackgroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      title: Text(
                        document.name,
                        style: const TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        document.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!_isChainDocument(document) &&
                                  document.signRequired)
                                ElevatedButton(
                                  onPressed: document.isSigned || hasRejected
                                      ? null
                                      : () => _signDocument(document.id, index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: document.isSigned
                                        ? const Color.fromARGB(255, 84, 162, 87)
                                        : const Color.fromARGB(
                                            255, 22, 79, 148),
                                  ),
                                  child: Text(
                                    document.isSigned
                                        ? 'Подписано'
                                        : 'Подписать',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: hasRejected
                                    ? null
                                    : () async {
                                        try {
                                          String downloadUrl =
                                              await documentService
                                                  .downloadDocument(
                                                      document.id);
                                          File pdfFile =
                                              await _downloadFile(downloadUrl);
                                          openPDF(pdfFile);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Ошибка скачивания документа: $e')),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 22, 79, 148),
                                ),
                                child: const Text(
                                  'Просмотреть',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (document.chainMetadata != null &&
                            document.chainMetadata!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, bottom: 16.0, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Цепочка подписей:',
                                  style: TextStyle(
                                    fontFamily: 'CeraPro',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...document.chainMetadata!.map(
                                  (chainItem) => Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(chainItem.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            _getStatusColor(chainItem.status),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.account_circle,
                                          size: 28,
                                          color:
                                              _getStatusColor(chainItem.status),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _employeeNames[
                                                        chainItem.employeeId] ??
                                                    chainItem.employeeId,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getStatusColor(
                                                      chainItem.status),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Подпись обязательна: ${chainItem.requiresSignature ? "Да" : "Нет"}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                'Статус: ${_statusLabel(chainItem.status)}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              if (currentUserId ==
                                                      chainItem.employeeId &&
                                                  chainItem.status == 0 &&
                                                  !hasRejected &&
                                                  chainItem.requiresSignature ==
                                                      true)
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _updateChainStatus(
                                                            document.id,
                                                            document
                                                                .chainMetadata!
                                                                .indexOf(
                                                                    chainItem),
                                                            0);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                      child: const Text(
                                                        'Подписать',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _updateChainStatus(
                                                            document.id,
                                                            document
                                                                .chainMetadata!
                                                                .indexOf(
                                                                    chainItem),
                                                            2);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                      child: const Text(
                                                        'Отклонить',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else if (currentUserId ==
                                                      chainItem.employeeId &&
                                                  chainItem.status == 0 &&
                                                  !hasRejected &&
                                                  chainItem.requiresSignature ==
                                                      false)
                                                (Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _updateChainStatus(
                                                            document.id,
                                                            document
                                                                .chainMetadata!
                                                                .indexOf(
                                                                    chainItem),
                                                            1);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                      child: const Text(
                                                        'Ознакомиться',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _updateChainStatus(
                                                            document.id,
                                                            document
                                                                .chainMetadata!
                                                                .indexOf(
                                                                    chainItem),
                                                            2);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                      child: const Text(
                                                        'Отклонить',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentViewPage extends StatefulWidget {
  final File file;

  const DocumentViewPage({Key? key, required this.file}) : super(key: key);

  @override
  DocumentViewPageState createState() => DocumentViewPageState();
}

class DocumentViewPageState extends State<DocumentViewPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Document"),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _isLoading = false;
              });
            },
            onError: (error) {
              setState(() {
                _isLoading = false;
              });
              print("Error rendering PDF: $error");
            },
            onPageError: (page, error) {
              print("Error on page $page: $error");
            },
            onViewCreated: (PDFViewController pdfViewController) {},
            onPageChanged: (int? page, int? total) {},
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
