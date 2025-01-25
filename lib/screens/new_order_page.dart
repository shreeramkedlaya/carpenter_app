// ignore_for_file: library_prefixes, avoid_print, deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:carpenter_app/components/const.dart';
import 'package:carpenter_app/components/text_field.dart';
import 'package:carpenter_app/models/item_model.dart';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';
import '../components/date_picker.dart';
import '../components/dropdowns/order_details_page.dart';
import '../components/dropdowns/status_dropdown.dart';
import '../components/vars.dart';
import '../models/status_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewOrderPage extends StatefulWidget {
  final bool isEditMode;
  const NewOrderPage({super.key, required this.isEditMode});

  @override
  NewOrderPageState createState() => NewOrderPageState();
}

class NewOrderPageState extends State<NewOrderPage> {
  // image source dialog
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

  // image picker dialog
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

  // Function to remove image
  void _removeImage(XFile imageFile) {
    setState(() {
      // Remove the imageFile from the list
      imageMeasurements.remove(imageFile);
      imagePatterns.remove(imageFile);
      imageMaterials.remove(imageFile);
    });
  }

  // Phone dialer
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
        UrlLauncher.launch(url);
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

  // Direct call
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

  // Launch WhatsApp
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

  // Bottom navigation bar
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    // Prevent navigation to the disabled tab
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // is edit mode enabled display Edit order else display New order
          // isEditMode ? 'Edit order' : 'New order',
          'New Order',
          style: TextStyle(color: white),
        ),
        backgroundColor: kBlue800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),

              // Customer mobile row
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
                  // launch phone dialer
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Choose an option'),
                              content: Text('Direct Call or Open Dialer?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openDirectCall();
                                  },
                                  child: Text('Direct Call'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openPhoneDialer();
                                  },
                                  child: Text('Open Dialer'),
                                ),
                              ],
                            );
                          });
                    },
                    child: Icon(Icons.phone),
                  ),
                  SizedBox(width: 10),
                  // launch whatsapp
                  GestureDetector(
                    onTap: () {
                      launchWhatsApp();
                    },
                    child: FaIcon(FontAwesomeIcons.whatsapp),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Name and place row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            hintText: 'Name',
                            readOnly: false,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: MyTextField(
                            hintText: 'Place',
                            readOnly: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

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
                            items: sampleItems,
                          ),
                        ),
                      );

                      if (selectedItems != null && selectedItems.isNotEmpty) {
                        setState(() {
                          controller.text = selectedItems.join(", ");
                        });
                      } else {
                        controller.text = "";
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 20),

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
                  Expanded(
                    child: StatusDropdown(
                      controller: statuscontroller,
                      hintText: 'Order Status',
                      statuses: statuses,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

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
                  Expanded(
                    child: MyTextField(
                      hintText: 'Paid Amount',
                      readOnly: false,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Measurements, Patterns, and Materials rows
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Measurements Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(
                                    'Measurements (${imageMeasurements.length})')),
                            GestureDetector(
                              onTap: () =>
                                  _showImageSourceDialog('measurements'),
                              child: Icon(Icons.camera_alt),
                            ),
                          ],
                        ),
                        if (imageMeasurements.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Display all images in the list with horizontal space between them
                                ...(imageMeasurements.map((imageFile) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        Image.file(File(imageFile.path),
                                            width: 150, height: 150),
                                        TextButton(
                                          onPressed: () =>
                                              _removeImage(imageFile),
                                          child: Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),

                        // Patterns Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child:
                                    Text('Patterns (${imagePatterns.length})')),
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
                              children: [
                                // Display all images in the list with horizontal space between them
                                ...(imagePatterns.map((imageFile) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        Image.file(File(imageFile.path),
                                            width: 150, height: 150),
                                        TextButton(
                                          onPressed: () =>
                                              _removeImage(imageFile),
                                          child: Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),

                        // Materials Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(
                                    'Materials (${imageMaterials.length})')),
                            GestureDetector(
                              onTap: () => _showImageSourceDialog('materials'),
                              child: Icon(Icons.camera_alt),
                            ),
                          ],
                        ),
                        if (imageMaterials.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Display all images in the list with horizontal space between them
                                ...(imageMaterials.map((imageFile) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        Image.file(File(imageFile.path),
                                            width: 150, height: 150),
                                        TextButton(
                                          onPressed: () =>
                                              _removeImage(imageFile),
                                          child: Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                          ),
                        // Adjust the container height dynamically based on whether materials images exist or not
                        if (imageMaterials.isEmpty)
                          SizedBox(
                              height:
                                  20), // Adjust height for empty materials list
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // voice note row
              Row(
                children: [
                  Expanded(
                    // child: Text('Voice Note'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Voice Note',
                              style: TextStyle(fontSize: 18)),
                        ),
                        IconButton(
                          icon: Icon(Icons.mic),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // add job switch if edit mode is enabled
              /* Row(
                children: [
                  Expanded(
                    child: Text('Add Jobs', style: TextStyle(fontSize: 18)),
                  ),
                  // for edit mode
                  Switch(
                    value: isViewJobEnabled,
                    onChanged: (value) {
                      setState(() {
                        isViewJobEnabled = value;
                        print('isViewJobEnabled: $isViewJobEnabled');
                      });
                    },
                  ),
                ],
              ), */
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'View',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
