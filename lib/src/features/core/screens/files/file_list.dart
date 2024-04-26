import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/features/core/screens/files/check_permission.dart';
import 'package:online_food_delivery_app/src/features/core/screens/files/directory_path.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Path;

class FileList extends StatefulWidget {
  const FileList({super.key});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  bool isPermission = false;
  var checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  var dataList = [
    {
      "id": "2",
      "title": "file Video 1",
      "url": "https://download.samplelib.com/mp4/sample-30s.mp4"
    },
    {
      "id": "3",
      "title": "file Video 2",
      "url": "https://download.samplelib.com/mp4/sample-20s.mp4"
    },
    {
      "id": "4",
      "title": "file Video 3",
      "url": "https://download.samplelib.com/mp4/sample-15s.mp4"
    },
    {
      "id": "5",
      "title": "file Video 4",
      "url": "https://download.samplelib.com/mp4/sample-10s.mp4"
    },
    {
      "id": "6",
      "title": "file PDF 6",
      "url":
          "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100080.pdf"
    },
    {
      "id": "10",
      "title": "file PDF 7",
      "url": "https://www.tutorialspoint.com/javascript/javascript_tutorial.pdf"
    },
    {
      "id": "10",
      "title": "C++ Tutorial",
      "url": "https://www.tutorialspoint.com/cplusplus/cpp_tutorial.pdf"
    },
    {
      "id": "11",
      "title": "file PDF 9",
      "url":
          "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100431.pdf"
    },
    {
      "id": "12",
      "title": "file PDF 10",
      "url": "https://www.tutorialspoint.com/java/java_tutorial.pdf"
    },
    {
      "id": "13",
      "title": "Image",
      "url":
          "https://firebasestorage.googleapis.com/v0/b/integrity-link.appspot.com/o/images%2FmErcSMVFYvbMV9qz7cRs9su6UmX2_jlCgTgcg9KT7UcTKEgCjW71Vqve2%2F1693860059545.jpg?alt=media&token=7ee63428-6751-4f0e-a3ea-30ab0dffca76&_gl=1*1juk28f*_ga*MjEyMTYxNzg4My4xNjk1NDUwNzky*_ga_CW55HF8NVT*MTY5NTg0NTcwNC4xMS4xLjE2OTU4NDU4MTMuNDEuMC4w"
    },
    {
      "id": "14",
      "title": "Expenditure Report",
      "url":
          "https://firebasestorage.googleapis.com/v0/b/integrity-link.appspot.com/o/Government%20Budgets%2FApp%20Presentation.pdf?alt=media&token=e0be70ce-60cf-4bb1-8e0d-00c6cb0f8068&_gl=1*17trnt*_ga*MjEyMTYxNzg4My4xNjk1NDUwNzky*_ga_CW55HF8NVT*MTY5NTg0NTcwNC4xMS4xLjE2OTU4NDU3NDcuMTcuMC4w"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isPermission
            ? ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = dataList[index];
                  return TileList(
                    fileUrl: data['url']!,
                    title: data['title']!,
                  );
                })
            : TextButton(
                onPressed: () {
                  checkPermission();
                },
                child: const Text("Permission issue")));
  }
}

class TileList extends StatefulWidget {
  const TileList({super.key, required this.fileUrl, required this.title});
  final String fileUrl;
  final String title;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  bool dowloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  late CancelToken cancelToken;
  var getPathFile = DirectoryPath();

  startDownload() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    setState(() {
      dowloading = true;
      progress = 0;
    });

    try {
      await Dio().download(widget.fileUrl, filePath,
          onReceiveProgress: (count, total) {
        setState(() {
          progress = (count / total);
        });
      }, cancelToken: cancelToken);
      setState(() {
        dowloading = false;
        fileExists = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        dowloading = false;
      });
    }
  }

  cancelDownload() {
    cancelToken.cancel();
    setState(() {
      dowloading = false;
    });
  }

  checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  openfile() {
    OpenFile.open(filePath);
    print("fff $filePath");
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      fileName = Path.basename(widget.fileUrl);
    });
    checkFileExit();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey.shade100,
      child: ListTile(
          title: Text(widget.title),
          leading: IconButton(
            onPressed: () {
              fileExists && dowloading == false ? openfile() : cancelDownload();
            },
            icon: fileExists && dowloading == false
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : const Icon(Icons.close),
          ),
          trailing: IconButton(
              onPressed: () {
                fileExists && dowloading == false
                    ? openfile()
                    : startDownload();
              },
              icon: fileExists
                  ? const Icon(
                      Icons.save,
                      color: Colors.green,
                    )
                  : dowloading
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                            Text(
                              (progress * 100).toStringAsFixed(2),
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        )
                      : const Icon(Icons.download))),
    );
  }
}
