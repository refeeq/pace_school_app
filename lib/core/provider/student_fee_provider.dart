import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/fees_list_model.dart';
import 'package:school_app/core/models/fees_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/models/transaction_model.dart';
import 'package:school_app/core/repository/student/repository.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/screens/student/fees_screen/payment_screen.dart';

import '../services/dependecyInjection.dart';

class StudentFeeProvider with ChangeNotifier {
  StudentRepository repository = locator<StudentRepository>();
  List<FeesModel> feeslistnew = [];
  StudentModel? studentModel;
  double totalAmount = 0.0;

  FeeListModel? feeListModel;

  AppStates feeListState = AppStates.Unintialized;
  AppStates feeViewState = AppStates.Unintialized;
  List<Transaction> studentFeeStatementlist = [];
  DataState studentFeeStatementlistState = DataState.Uninitialized;

  int _currentPageNumber = 0; // Current Page to get Data from API

  bool _didLastLoad =
      false; // Property through which we can check if last page have been loaded from API or not

  List<Transaction> _studentFeeStatementlist = []; // List Containing the data
  dynamic feeViewRes;

  String pending_fee = '';
  String? _pendingFeeRequestStudentId;

  List<Transaction> get dataList =>
      _studentFeeStatementlist; // getters of List of Data

  DataState get dataState =>
      studentFeeStatementlistState; // getters of State of Data

  Future<void> getStudentFee({required String studentId}) async {
    _pendingFeeRequestStudentId = studentId;
    totalAmount = 0.0;
    feeListModel = null;
    notifyListeners();
    feeListState = AppStates.Initial_Fetching;

    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      _pendingFeeRequestStudentId = null;
      feeListState = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.getStudentFee(studCode: studentId);
      if (respon.isLeft) {
        _pendingFeeRequestStudentId = null;
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        feeListState = AppStates.Error;
      } else {
        if (respon.right.status == true) {
          final respStudCode = respon.right.studentModel.studcode;
          if (_pendingFeeRequestStudentId != null &&
              respStudCode != _pendingFeeRequestStudentId) {
            _pendingFeeRequestStudentId = null;
            notifyListeners();
            return;
          }
          _pendingFeeRequestStudentId = null;
          feeListState = AppStates.Fetched;
          //  showToast(respon.right.message);
          log(respon.right.data.toString());
          feeListModel = respon.right;
          feeslistnew.clear();
          feeslistnew.clear();
          studentModel = respon.right.studentModel;
          if (respon.right.chkboxReadOnly) {
            for (var element in respon.right.data) {
              FeesModel feesModel = element;
              feesModel.isSelected = true;
              feeslistnew.add(feesModel);
              totalAmount = totalAmount + double.parse(element.feeAmt);
            }
          } else {
            // respon.right.data.forEach((element) {
            //   FeesModel feesModel = element;
            //   feesModel.isSelected = true;

            //   totalAmount = totalAmount + double.parse(element.feeAmt);
            // });
            feeslistnew = respon.right.data;
            for (var element in feeslistnew) {
              if (element.isSelected) {
                totalAmount = totalAmount + double.parse(element.feeAmt);
              }
            }
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> getStudentFeeStatementlist({
    bool isRefresh = false,
    required String studeCode,
  }) async {
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!isRefresh) {
      studentFeeStatementlistState =
          (studentFeeStatementlistState == DataState.Uninitialized)
          ? DataState.Initial_Fetching
          : DataState.More_Fetching;
      notifyListeners();
    } else {
      studentModel = null;
      _didLastLoad = false;

      _currentPageNumber = 0;
      if (!hasInternet) {
        studentFeeStatementlistState = DataState.NoInterNetConnectionState;
      }
      _studentFeeStatementlist.clear();
      studentFeeStatementlistState = DataState.Initial_Fetching;
      notifyListeners();
    }
    notifyListeners();

    if (hasInternet) {
      try {
        if (_didLastLoad) {
          studentFeeStatementlistState = DataState.No_More_Data;
        } else {
          var respon = await repository.getStudentFeeStatement(
            studCode: studeCode,
            limitTwo: _currentPageNumber,
          );
          if (respon.isLeft) {
            log(respon.left.message.toString());
            log(respon.left.key.toString());
            studentFeeStatementlistState = DataState.Error;
          } else {
            if (isRefresh) {
              _studentFeeStatementlist.clear();
            }
            studentFeeStatementlistState = DataState.Fetched;
            pending_fee = respon.right["defAmt"];
            studentModel = StudentModel.fromJson(
              respon.right["studentDetails"],
            );
            List<Transaction> alist = List<Transaction>.from(
              respon.right["transactions"].map((x) => Transaction.fromJson(x)),
            );
            List<Transaction> list = alist;
            if (_studentFeeStatementlist.isEmpty && list.isEmpty) {
              _studentFeeStatementlist = [];
            } else if (list.isEmpty) {
              // _studentFeeStatementlist = [];
              _didLastLoad = true;
            } else {
              _studentFeeStatementlist += list;

              _currentPageNumber += 1;
            }
          }
        }
        notifyListeners();
      } catch (e) {
        studentFeeStatementlistState = DataState.Error;
        notifyListeners();
      }
    }
  }

  Future<void> postStudentFee(BuildContext context, String studcode) async {
    showAlertLoader(context);
    List<FeesModel> feeslistSelected = [];
    for (var element in feeslistnew) {
      if (element.isSelected) {
        feeslistSelected.add(element);
      }
    }

    notifyListeners();
    final effectiveStudCode =
        studentModel?.studcode ?? studcode;
    var respon = await repository.getStudentFeeSubmit(
      studCode: effectiveStudCode,
      list: feeslistSelected,
    );
    if (respon.isLeft) {
      Navigator.pop(context);
      showToast(respon.left.message.toString(), context);
      log(respon.left.message.toString());
      log(respon.left.key.toString());
      //   feeListState = AppStates.Error;
    } else {
      Navigator.pop(context);
      if (respon.right.status == true) {
        // feeListState = AppStates.Fetched;
        // showToast(respon.right.message);
        // log(respon.right.data.toString());
        //  feeListModel = respon.right;
        //  feeslistnew.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              isPayment: true,
              reponseUrl: respon.right.data,
              userId: effectiveStudCode,
            ),
          ),
        );
        // launchUrl(Uri.parse(respon.right.data));
      } else {}
    }
    notifyListeners();
  }

  void updateAmount(bool value, String amount) {
    if (value) {
      totalAmount = totalAmount + double.parse(amount);
      log('addition');

      log(totalAmount.toString());
    } else {
      totalAmount = totalAmount - double.parse(amount);
      log('dde');
      log(double.parse(amount).toString());
      log(totalAmount.toString());
    }
  }

  void updateValue(int index, bool value) {
    totalAmount = 0;
    feeslistnew[index].isSelected = value;
    for (var element in feeslistnew) {
      if (element.isSelected) {
        totalAmount = totalAmount + double.parse(element.feeAmt);
      }
    }
    notifyListeners();
  }

  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    feeslistnew = [];
    studentModel = null;
    totalAmount = 0.0;
    feeListModel = null;
    feeListState = AppStates.Unintialized;
    feeViewState = AppStates.Unintialized;
    studentFeeStatementlist = [];
    studentFeeStatementlistState = DataState.Uninitialized;
    _currentPageNumber = 0;
    _didLastLoad = false;
    _studentFeeStatementlist = [];
    feeViewRes = null;
    pending_fee = '';
    _pendingFeeRequestStudentId = null;
    notifyListeners();
  }

  Future<void> viewRcpt({required String type, no, studCode}) async {
    feeViewState = AppStates.Initial_Fetching;
    feeViewRes = null;

    var res = await repository.viewStudentRcpts(
      studCode: studCode,
      type: type,
      no: no,
    );
    feeViewRes = res.right;
    feeViewState = AppStates.Fetched;
    notifyListeners();
  }
}
