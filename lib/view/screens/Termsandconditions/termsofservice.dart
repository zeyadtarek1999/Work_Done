import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class termsOfService extends StatelessWidget {
  termsOfService({Key? key}) : super(key: key);

  String termsText = """
Last updated March 11th, 2024.

Please read this Terms of Service ("Terms," "Terms & Conditions ") carefully before using the Mobile Application (the “Application”) or (www.workdonecorp.com) (the "Website") operated by the US WORKDONE CORP., a corporation formed in Delaware, United States ("us," "we," "our") as this Terms & Conditions contain important information regarding limitations of our liability. Your access to and use of the Application or Website is conditional upon your acceptance of and compliance with these Terms. These Terms apply to everyone, including but not limited to visitors, users, and others, who wish to access and use the Application or Website. By accessing or using the Application, Website, or any contents that belong to the US WORKDONE CORP., you agree to be bound by these Terms. If you disagree with any part of the Terms, then you do not have our permission to access or use both the Application and Website.

Section 1. Definitions and Interpretation

1.1 In these Terms and Conditions, the following words and expressions shall have the following meanings:
•	"US WORKDONE CORP." refers to the platform and services provided by US WORKDONE CORP., including its website and mobile application.
•	"Client" refers to any individual or entity utilizing the services offered by US WORKDONE CORP. to obtain assistance with various home improvement tasks.
•	"Worker" refers to any individual or entity offering services through US WORKDONE CORP. to assist Clients with their tasks.
•	"Platform" refers to the web and app-based marketplace operated by US WORKDONE CORP., connecting Clients with Workers for task completion.

Section 2. Acceptance of Terms
2.1 By accessing or using the US WORKDONE CORP. platform, you agree to be bound by these Terms and Conditions. 2.2 These Terms and Conditions govern your use of the US WORKDONE CORP. platform and supersede any prior agreements or understandings between you and US WORKDONE CORP. 2.3 If you do not agree to these Terms and Conditions, you may not access or use the US WORKDONE CORP. platform.

Section 3. Services Provided
3.1 US WORKDONE CORP., provides a platform that facilitates connections between Clients seeking assistance with various tasks and Workers offering their services to fulfill those tasks. 3.2 Clients may submit project details, including descriptions, photos, and videos, to the platform, and Workers may bid on these projects based on their expertise and availability. 3.3 Upon selection of a bid by a Client, US WORKDONE CORP. facilitates communication between the Client and the Worker to finalize project details and scheduling. 3.4 US WORKDONE CORP. does not provide any services directly but acts as a facilitator between Clients and Workers. Any agreements or contracts entered into between Clients and Workers are solely between those parties, and evidence shall be reviewed by US WORKDONE CORP. to better serve both parties.

Section 4. Billing and Payments
4.1 Clients shall be responsible for the payment of agreed-upon fees to Workers for services rendered. US WORKDONE CORP. may facilitate payment processing services to streamline these transactions. 4.2 Workers may be required to acquire credits or remit a commission fee to US WORKDONE CORP. for access to project opportunities on the platform. 4.3 US WORKDONE CORP. reserves the right to levy additional charges for premium features or services rendered on the platform, as delineated in the respective terms and conditions. 4.4 All billing and payment particulars shall be subject to the terms and conditions stipulated by US WORKDONE CORP.'s designated payment gateway provider. 4.5 US WORKDONE CORP. shall retain the funds remitted by the client upon acceptance of the bid. 4.6 Workers shall receive payment corresponding precisely to the amount specified in the bid upon completion of the project, as marked by the client upon pressing the "Complete Project" button. 4.7 US WORKDONE CORP. reserves the right to securely hold funds on the platform in the event of any conflicts reported by either the client or the worker.

Section 5. Limitation of Liability
5.1 EXCLUSION OF DAMAGES: US WORKDONE CORP. SHALL NOT BE LIABLE FOR ANY DAMAGES, LOSSES, OR LIABILITIES ARISING OUT OF OR IN CONNECTION WITH THE USE OF ITS PLATFORM OR SERVICES. THIS INCLUDES, BUT IS NOT LIMITED TO, DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, LOSS OF PROFITS, GOODWILL, DATA, OR OTHER INTANGIBLE LOSSES. 5.2 QUALITY OF SERVICES: WHILE US WORKDONE CORP. ENDEAVORS TO ENSURE OPTIMUM QUALITY PROVIDED BY WORKERS, IT DOES NOT GUARANTEE THE QUALITY, ACCURACY, OR SUITABILITY OF SERVICES PROVIDED BY WORKERS. CLIENTS ACKNOWLEDGE THAT THE PLATFORM ACTS SOLELY AS A FACILITATOR BETWEEN CLIENTS AND WORKERS. THEREFORE, CLIENTS ARE ENCOURAGED TO CONDUCT THEIR OWN DUE DILIGENCE BEFORE ENGAGING A WORKER FOR ANY TASK. 5.3 DISPUTES AND BREACHES: US WORKDONE CORP. SHALL NOT BE LIABLE FOR ANY DISPUTES, DISAGREEMENTS, OR BREACHES OF CONTRACT BETWEEN CLIENTS AND WORKERS. ANY CONTRACTUAL ARRANGEMENTS ENTERED INTO BETWEEN CLIENTS AND WORKERS ARE SOLELY BETWEEN THOSE PARTIES. US WORKDONE CORP. SHALL NOT HAVE ANY LIABILITY FOR THE ACTIONS OR OMISSIONS OF ANY USERS OF THE PLATFORM.

Section 6. Dispute Resolution
6.1 Assistance Provided: In the event of any disputes between Clients and Workers, US WORKDONE CORP. may, at its discretion, provide dispute resolution services to facilitate resolution. Such assistance may include mediation, arbitration, or other forms of alternative dispute resolution. 6.2 Cooperation of Parties: Clients and Workers agree to cooperate in good faith to resolve any disputes promptly and amicably. Both parties agree to provide all necessary information and documentation to US WORKDONE CORP. to facilitate the resolution process. 6.3 Final Decision: US WORKDONE CORP.'s decision in any dispute resolution process shall be final and binding on all parties involved. CLIENTS AND WORKERS AGREE TO ABIDE BY THE DECISION REACHED THROUGH THE DISPUTE RESOLUTION PROCESS AND WAIVE ANY FURTHER CLAIMS OR ACTIONS AGAINST US WORKDONE CORP. ARISING FROM THE DISPUTE.

Section 7. Intellectual Property
7.1 Ownership: US WORKDONE CORP. retains all rights, title, and interest in and to its platform, including but not limited to its website, mobile application, trademarks, logos, patents, and intellectual property. Users acknowledge and agree that they do not acquire any ownership rights in the platform or its contents by using the US WORKDONE CORP. platform. 7.2 Restrictions: Users agree not to reproduce, modify, distribute, display, or transmit any content from the US WORKDONE CORP. platform without prior written consent from US WORKDONE CORP. Any unauthorized use of the platform's content may constitute a violation of intellectual property rights and may result in legal action.


Section 8. Governing Law
8.1 These Terms and Conditions shall be governed by and construed in accordance with the laws of The State of Washington, without regard to its conflict of law provisions. 8.2 Any disputes arising out of or in connection with these Terms and Conditions shall be subject to the exclusive jurisdiction of the courts of The State of Washington.

Section 9. Severability
9.1 If any provision of these Terms and Conditions is found to be unenforceable or invalid, such provision shall be deemed modified to the minimum extent necessary to make it enforceable, and the validity and enforceability of the remaining provisions shall not be affected.

Section 10. Entire Agreement
10.1 THESE TERMS AND CONDITIONS CONSTITUTE THE ENTIRE AGREEMENT BETWEEN USERS AND US WORKDONE CORP. REGARDING THE USE OF ITS PLATFORM AND SERVICES, SUPERSEDING ANY PRIOR AGREEMENTS OR UNDERSTANDINGS, WHETHER WRITTEN OR ORAL.

Section 11. Amendments
11.1 US WORKDONE CORP. reserves the right to modify, amend, or change these Terms and Conditions at any time without prior notice. Users are responsible for regularly reviewing these Terms and Conditions to stay informed of any updates or changes. Continued use of the US WORKDONE CORP. platform after such modifications shall constitute acceptance of the revised Terms and Conditions.

  """;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:       Colors.white,

      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return Scaffold(
      backgroundColor: HexColor('ECECEC'),
      appBar: AppBar(
        backgroundColor: HexColor('ECECEC'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Terms Of Service',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12.0),
            child: Text(
              termsText,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
