class DocumentModel {
  String? success;
  String? error;
  String? message;
  List<DocumentData>? documentList;

  DocumentModel({this.success, this.error, this.message, this.documentList});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    error = json['error'].toString();
    message = json['message'].toString();
    // Safely parse data list - handle String, List, or null
    var dataRaw = json['data'];
    if (dataRaw != null && dataRaw is List && dataRaw.isNotEmpty) {
      documentList = <DocumentData>[];
      for (var v in dataRaw) {
        documentList!.add(DocumentData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (documentList != null) {
      data['data'] = documentList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DocumentData {
  String? id;
  String? title;
  String? isEnabled;
  String? createdAt;
  String? updatedAt;

  DocumentData(
      {this.id, this.title, this.isEnabled, this.createdAt, this.updatedAt});

  DocumentData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'].toString();
    isEnabled = json['is_enabled'].toString();
    createdAt = json['created_at'].toString();
    updatedAt = json['updated_at'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['is_enabled'] = isEnabled;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
