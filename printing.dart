import 'dart:convert';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrintService {
  static final PrinterNetworkManager printerManager = PrinterNetworkManager();

  static Future<String> printReceipt(
      String orderJson, String ip, int printerPort) async {
    printerManager.selectPrinter(ip, port: printerPort);
    final PosPrintResult res =
        await printerManager.printTicket(await testTicket(orderJson));
    return 'Print result: ${res.msg}';
  }

  static Future<Ticket> testTicket(String messageText) async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(PaperSize.mm80, profile);
    Map order = jsonDecode(messageText);
    PosAlign globalAlignment = PosAlign.left;
    PosTextSize globalSize = PosTextSize.size1;
    bool globalBold = false;
    bool globalReverse = false;
    bool globalUnderLine = false;

    if (order.containsKey("OrderDetails")) {
      for (int i = 0; i < order["OrderDetails"].length; i++) {
        if (order["OrderDetails"][i].containsKey("type")) {
          if (order["OrderDetails"][i]["type"] == "text") {
            if (order["OrderDetails"][i].containsKey("text")) {
              ticket.text(
                order["OrderDetails"][i]["text"],
                styles: PosStyles(
                  align: order["OrderDetails"][i].containsKey("alignment")
                      ? order["OrderDetails"][i]["alignment"] == "left"
                          ? PosAlign.left
                          : order["OrderDetails"][i]["alignment"] == "right"
                              ? PosAlign.right
                              : PosAlign.center
                      : globalAlignment,
                  bold: order["OrderDetails"][i].containsKey("weight")
                      ? order["OrderDetails"][i]["weight"] == "bold"
                          ? true
                          : false
                      : globalBold,
                  reverse: order["OrderDetails"][i].containsKey("reverse")
                      ? order["OrderDetails"][i]["reverse"] == "true"
                          ? true
                          : false
                      : globalReverse,
                  underline: order["OrderDetails"][i].containsKey("underline")
                      ? order["OrderDetails"][i]["underline"] == "true"
                          ? true
                          : false
                      : globalUnderLine,
                  height: order["OrderDetails"][i].containsKey("size")
                      ? order["OrderDetails"][i]["size"] == "small"
                          ? PosTextSize.size1
                          : order["OrderDetails"][i]["size"] == "normal"
                              ? PosTextSize.size2
                              : PosTextSize.size3
                      : globalSize,
                  width: order["OrderDetails"][i].containsKey("size")
                      ? order["OrderDetails"][i]["size"] == "small"
                          ? PosTextSize.size1
                          : order["OrderDetails"][i]["size"] == "normal"
                              ? PosTextSize.size2
                              : PosTextSize.size3
                      : globalSize,
                ),
              );
            }
          } else if (order["OrderDetails"][i]["type"] == "EmptyLines") {
            ticket.feed(order["OrderDetails"][i].containsKey("number")
                ? int.parse(order["OrderDetails"][i]["number"])
                : 1);
          } else if (order["OrderDetails"][i]["type"] == "CharLine") {
            if (order["OrderDetails"][i].containsKey("char")) {
              ticket.hr(ch: order["OrderDetails"][i]["char"]);
            }
          } else if (order["OrderDetails"][i]["type"] == "Left-Right") {
            if (order["OrderDetails"][i].containsKey("Left") &&
                order["OrderDetails"][i].containsKey("Right")) {
              if (order["OrderDetails"][i]["Left"].containsKey("text") &&
                  order["OrderDetails"][i]["Right"].containsKey("text")) {
                ticket.row([
                  PosColumn(
                    text: order["OrderDetails"][i]["Left"]["text"],
                    width: 6,
                    styles: PosStyles(
                      align: PosAlign.left,
                      height: order["OrderDetails"][i]["Left"]
                              .containsKey("size")
                          ? order["OrderDetails"][i]["Left"]["size"] == "small"
                              ? PosTextSize.size1
                              : order["OrderDetails"][i]["Left"]["size"] ==
                                      "normal"
                                  ? PosTextSize.size2
                                  : PosTextSize.size3
                          : globalSize,
                      width: order["OrderDetails"][i]["Left"]
                              .containsKey("size")
                          ? order["OrderDetails"][i]["Left"]["size"] == "small"
                              ? PosTextSize.size1
                              : order["OrderDetails"][i]["Left"]["size"] ==
                                      "normal"
                                  ? PosTextSize.size2
                                  : PosTextSize.size3
                          : globalSize,
                      underline: order["OrderDetails"][i]["Left"]
                              .containsKey("underline")
                          ? order["OrderDetails"][i]["Left"]["underline"] ==
                                  "true"
                              ? true
                              : false
                          : globalUnderLine,
                      bold: order["OrderDetails"][i]["Left"]
                              .containsKey("weight")
                          ? order["OrderDetails"][i]["Left"]["weight"] == "bold"
                              ? true
                              : false
                          : globalBold,
                      reverse: order["OrderDetails"][i]["Left"]
                              .containsKey("reverse")
                          ? order["OrderDetails"][i]["Left"]["reverse"] ==
                                  "true"
                              ? true
                              : false
                          : globalReverse,
                    ),
                  ),
                  PosColumn(
                    text: order["OrderDetails"][i]["Right"]["text"],
                    width: 6,
                    styles: PosStyles(
                      align: PosAlign.left,
                      height: order["OrderDetails"][i]["Right"]
                              .containsKey("size")
                          ? order["OrderDetails"][i]["Right"]["size"] == "small"
                              ? PosTextSize.size1
                              : order["OrderDetails"][i]["Right"]["size"] ==
                                      "normal"
                                  ? PosTextSize.size2
                                  : PosTextSize.size3
                          : globalSize,
                      width: order["OrderDetails"][i]["Right"]
                              .containsKey("size")
                          ? order["OrderDetails"][i]["Right"]["size"] == "small"
                              ? PosTextSize.size1
                              : order["OrderDetails"][i]["Right"]["size"] ==
                                      "normal"
                                  ? PosTextSize.size2
                                  : PosTextSize.size3
                          : globalSize,
                      underline: order["OrderDetails"][i]["Right"]
                              .containsKey("underline")
                          ? order["OrderDetails"][i]["Right"]["underline"] ==
                                  "true"
                              ? true
                              : false
                          : globalUnderLine,
                      bold: order["OrderDetails"][i]["Right"]
                              .containsKey("weight")
                          ? order["OrderDetails"][i]["Right"]["weight"] ==
                                  "bold"
                              ? true
                              : false
                          : globalBold,
                      reverse: order["OrderDetails"][i]["Right"]
                              .containsKey("reverse")
                          ? order["OrderDetails"][i]["Right"]["reverse"] ==
                                  "true"
                              ? true
                              : false
                          : globalReverse,
                    ),
                  ),
                ]);
              }
            }
          } else if (order["OrderDetails"][i]["type"] == "style") {
            if (order["OrderDetails"][i].containsKey("size")) {
              if (order["OrderDetails"][i]["size"] == "small") {
                globalSize = PosTextSize.size1;
              } else if (order["OrderDetails"][i]["size"] == "normal") {
                globalSize = PosTextSize.size2;
              } else {
                globalSize = PosTextSize.size3;
              }
            }
            if (order["OrderDetails"][i].containsKey("alignment")) {
              if (order["OrderDetails"][i]["alignment"] == "left") {
                globalAlignment = PosAlign.left;
              } else if (order["OrderDetails"][i]["alignment"] == "center") {
                globalAlignment = PosAlign.center;
              } else {
                globalAlignment = PosAlign.right;
              }
            }
            if (order["OrderDetails"][i].containsKey("reverse")) {
              if (order["OrderDetails"][i]["reverse"] == "true") {
                globalReverse = true;
              } else {
                globalReverse = false;
              }
            }
            if (order["OrderDetails"][i].containsKey("weight")) {
              if (order["OrderDetails"][i]["weight"] == "bold") {
                globalBold = true;
              } else {
                globalBold = false;
              }
            }
            if (order["OrderDetails"][i].containsKey("underline")) {
              if (order["OrderDetails"][i]["underline"] == "true") {
                globalUnderLine = true;
              } else {
                globalUnderLine = false;
              }
            }
          }
        }
      }
    }
    ticket.feed(2);
    ticket.cut();
    return ticket;
  }
}
