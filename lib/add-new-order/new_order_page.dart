// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:carpenter_app/components/const.dart';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher.dart';
import 'date_picker.dart';
import '../order-list/order_list.dart';
import 'order_details_dropdown.dart';
import 'status_dropdown.dart';
import '../components/my_button.dart';
import '../components/text_field.dart';
import '../components/vars.dart';
import '../models/item_model.dart';
import 'status_model.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({
    super.key,
  });

  @override
  NewOrderPageState createState() => NewOrderPageState();
}

class NewOrderPageState extends State<NewOrderPage> {
  Future<void> _showImageSourceDialog(String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick an image source'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(type, fromCamera: true); // Pick from camera
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(type, fromCamera: false); // Pick from gallery
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(String type, {bool fromCamera = true}) async {
    final ImageSource source =
        fromCamera ? ImageSource.camera : ImageSource.gallery;
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final img.Image? image = img.decodeImage(await pickedFile.readAsBytes());

      if (image != null) {
        // Compress the image with reduced quality (e.g., 85 to decrease file size)
        final compressedImage =
            img.encodeJpg(image, quality: 85); // Adjust quality as needed

        // Get the temporary directory path to store the compressed file
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Save the compressed image to the file asynchronously
        final file = File(filePath);
        await file.writeAsBytes(compressedImage); // Asynchronous write

        // Create a new XFile with the compressed image file
        final compressedFile = XFile(filePath);

        // Update the state based on the type
        setState(() {
          if (type == 'measurements') {
            imageMeasurements.add(compressedFile);
          } else if (type == 'patterns') {
            imagePatterns.add(compressedFile);
          } else if (type == 'materials') {
            imageMaterials.add(compressedFile);
          }
        });
      }
    }
  }

  void _removeImage(XFile imageFile) {
    setState(() {
      // Remove the imageFile from the list
      imageMeasurements.remove(imageFile);
      imagePatterns.remove(imageFile);
      imageMaterials.remove(imageFile);
    });
  }

  void _openPhoneDialer() async {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      // Handle the condition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number is required'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Phone Number should be greater than ${phoneNumber.length} digits and equal to 10 digits'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else {
      final url = "tel://$phoneNumber"; // Format the phone number with 'tel://'
      print('Launching phone dialer with $url');
      try {
        print('launching $url');
        url_launcher.launch(url);
      } catch (e) {
        print('Error launching phone dialer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching phone dialer: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openDirectCall() async {
    final dialer = await DirectDialer.instance;
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      // Handle the condition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number is required'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Phone Number should be greater than ${phoneNumber.length} digits and equal to 10 digits',
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else {
      try {
        await dialer.dial(phoneController.text.trim());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching phone dialer: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void launchWhatsApp() async {
    String phoneNumber = phoneController.text.trim();
    final String url =
        "https://wa.me/$phoneNumber?text=Hello%20from%20Carpenter%20App";
    if (phoneNumber.isEmpty) {
      // Handle the condition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number is required'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Phone Number should be greater than ${phoneNumber.length} digits and equal to 10 digits',
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else {
      if (await launch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    }
  }

  Future<void> _startRecording() async {
    if (isPermissionGranted) {
      final tempDir = await getTemporaryDirectory();
      audioPath =
          '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.aac';
      await audioRecorder.startRecorder(toFile: audioPath);
      setState(() {
        isRecording = true;
        hasRecording = false; // Reset previous recording state
      });

      // Start a timer to stop recording after 60 seconds
    } else {
      checkAndRequestPermission();
    }
  }

  Future<void> _stopRecording() async {
    await audioRecorder.stopRecorder();
    setState(() {
      isRecording = false;
      hasRecording = true; // Now we have a recorded file
    });
  }

  Future<void> checkAndRequestPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      setState(() {
        isPermissionGranted = true;
      });
    } else {
      final newStatus = await Permission.microphone.request();
      if (newStatus.isGranted) {
        setState(() {
          isPermissionGranted = true;
        });
      } else {
        _showPermissionError();
      }
    }
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Permission to access microphone is denied."),
    ));
  }

  void _removeVoiceNote(String path) {
    if (audioPath != null) {
      stopAudio();
      File(audioPath!).deleteSync();
    }
    setState(() {
      audioPath = null;
      hasRecording = false; // Reset UI
    });
  }

  Future<void> playVoiceNote(String path) async {
    await audioPlayer.openPlayer();
    if (audioPath == null) return;
    try {
      await audioPlayer.startPlayer(
          fromURI: audioPath,
          whenFinished: () {
            setState(() {
              isPlaying = false;
            });
          });
      setState(() => isPlaying = true);
      print('playing audio $audioPath');
    } catch (e) {
      print('Error playing audio $e');
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stopPlayer();
    setState(() => isPlaying = false);
  }

  Future<void> initRecorderPlayer() async {
    try {
      // Open the recorder
      await audioRecorder.openRecorder();
      isRecorderInitialized = true;

      // Open the player
      await audioPlayer.openPlayer();
      isPlayerInitialized = true;

      print("Recorder and Player initialized successfully!");
    } catch (e) {
      print("Error initializing recorder/player: $e");
    }
  }

  Future<void> confirmOrder() async {
    /* try {
      // Check if the order has an ID (order exists in DB) or not
      final dbHelper = DatabaseService();

      if (newOrder != null) {
        // If order exists, update it
        await dbHelper.saveOrUpdateOrder(newOrder);
      } else {
        // If order doesn't exist, save it and reset form
        await dbHelper.saveOrUpdateOrder(newOrder!);
        resetOrderForm(); // Assuming this method is defined elsewhere to reset form
      }

      print('Order and all images saved or updated successfully.');

      // Assuming you have audio operations to stop and close as in your original function
      await audioRecorder.stopRecorder();
      await audioRecorder.closeRecorder();
      await audioPlayer.stopPlayer();
      await audioPlayer.closePlayer();

      // Navigate to the order list page (replace as needed)
      
      );
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error saving or updating order: $error');
    } */
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OrderListPage()));
    print('dispossed successfully');
  }

  @override
  void initState() {
    checkAndRequestPermission();
    initRecorderPlayer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    audioRecorder.stopRecorder();
    audioRecorder.closeRecorder();
    audioPlayer.stopPlayer();
    audioPlayer.closePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Order',
          style: TextStyle(color: white),
        ),
        backgroundColor: kBlue800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // main column for the page
            children: [
              // top container
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: phoneController,
                      hintText: 'Customer Mobile',
                      icon: Icons.search,
                      readOnly: false,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Choose Action'),
                              content: Text(
                                  'Would you like to make a direct call or open the dialer?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Direct Call'),
                                  onPressed: () {
                                    _openDirectCall();
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                                TextButton(
                                  child: Text('Open Dialer'),
                                  onPressed: () {
                                    _openPhoneDialer();
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    child: Icon(Icons.phone),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: launchWhatsApp,
                    child: FaIcon(FontAwesomeIcons.whatsapp),
                  )
                ],
              ),

              SizedBox(height: 15),

              // Name and place row
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      hintText: 'Name',
                      readOnly: false,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MyTextField(
                      hintText: 'Place',
                      readOnly: false,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              // Order details row
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: controller,
                      hintText: 'Order Details',
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    onPressed: () async {
                      final selectedItems = await Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(
                            items:
                                sampleItems, // Assuming sampleItems is passed to the next page
                          ),
                        ),
                      );

                      if (selectedItems != null && selectedItems.isNotEmpty) {
                        setState(() {
                          // Update the TextField with the selected items
                          controller.text = selectedItems.join(", ");
                        });
                      } else {
                        // Clear the TextField if no items were selected
                        setState(() {
                          controller.text = "";
                        });
                      }
                    },
                  )
                ],
              ),

              SizedBox(height: 15),

              // Due date and order status row
              Row(
                children: [
                  Expanded(
                    child: DatePicker(
                      controller: dateController,
                      hintText: 'Due Date',
                      initialDate: DateTime.now(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatusDropdown(
                      controller: statusController,
                      hintText: 'Order Status',
                      statuses: statuses,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              // Bill amount and paid amount row
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      hintText: 'Bill Amount',
                      readOnly: false,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MyTextField(
                      hintText: 'Paid Amount',
                      readOnly: false,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              // Measurements, Patterns, and Materials rows
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Measurements Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Measurements (${imageMeasurements.length})'),
                          GestureDetector(
                            onTap: () => _showImageSourceDialog('measurements'),
                            child: Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                      if (imageMeasurements.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: imageMeasurements.map((imageFile) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Image.file(File(imageFile.path),
                                        width: 150, height: 150),
                                    TextButton(
                                      onPressed: () => _removeImage(imageFile),
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(height: 20),

                      // patterns row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Patterns (${imagePatterns.length})'),
                          GestureDetector(
                            onTap: () => _showImageSourceDialog('patterns'),
                            child: Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                      if (imagePatterns.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: imagePatterns.map((imageFile) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Image.file(File(imageFile.path),
                                        width: 150, height: 150),
                                    TextButton(
                                      onPressed: () => _removeImage(imageFile),
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(height: 20),

                      // materials row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Materials (${imageMaterials.length})'),
                          GestureDetector(
                            onTap: () => _showImageSourceDialog('measurements'),
                            child: Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                      if (imageMaterials.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: imageMaterials.map((imageFile) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Image.file(File(imageFile.path),
                                        width: 150, height: 150),
                                    TextButton(
                                      onPressed: () => _removeImage(imageFile),
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              // voice note row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Voice Note',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        // If recording, show stop button
                        if (isRecording)
                          IconButton(
                            icon: Icon(Icons.stop, color: kRed800),
                            onPressed: _stopRecording,
                          )
                        // If there's no recording, show mic icon
                        else if (!hasRecording)
                          IconButton(
                            icon: Icon(Icons.mic, color: kBlue800),
                            onPressed: _startRecording,
                          )
                        // If recording exists, show play & delete buttons
                        else ...[
                          IconButton(
                            icon: Icon(Icons.delete, color: kRed800),
                            onPressed: () => _removeVoiceNote(audioPath!),
                          ),
                          IconButton(
                            icon:
                                Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                            onPressed: isPlaying
                                ? stopAudio
                                : () => playVoiceNote(audioPath!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // center confirm button
              Center(
                child: MyButton(
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: white),
                  ),
                  onPressed: () {
                    confirmOrder();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
