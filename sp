create or replace PROCEDURE        SP_ESB_RECEIPT_OFFLINE_JSON_RECEIPT (
IN_RequestID In varchar2,
IN_APP_NO In varchar2,
IN_RequestJSON	  In CLOB,
OP_RESPONSE_JSON OUT CLOB
)
IS
 v_OR_NUM VARCHAR2(10);
 v_LAST_NUMBER VARCHAR2(10);
 -- v_DEPARTMENTTYPENAME VARCHAR2(30);
 v_PlanName VARCHAR2(100);
 v_AgentName VARCHAR2(100);
 v_DescCode VARCHAR2(25);
 v_count VARCHAR2(5);
 v_DeptBranchCode NUMBER(5);
 v_PAYTYPE VARCHAR2(1 BYTE);
 v_reqId				VARCHAR2(10 BYTE):=IN_RequestID;
v_AppNum			VARCHAR2(10 BYTE):=IN_RequestID;
v_APPL_RCV_DT			VARCHAR2(25);
p_WS_CALL          VARCHAR2(10);
p_RESPONSE_FLAG    VARCHAR2(5000);
strErr             VARCHAR2(5000);

BEGIN

dbms_output.put_line( 'OR Number Generation Start' );

SELECT last_number+1
  INTO v_LAST_NUMBER
  FROM ortable
  WHERE user_id = 'INGRP2755' AND NVL(CLOSE_SERIES,'N') <> 'Y' order by issue_date;

v_OR_NUM := v_LAST_NUMBER;
dbms_output.put_line( 'OR Number Generation End : '||v_OR_NUM);

dbms_output.put_line( 'OR Number update in ortable Start' );

update ortable set last_number = v_OR_NUM, prev_updt_ts = CURRENT_TIMESTAMP  WHERE user_id = 'INGRP2755' AND NVL(CLOSE_SERIES,'N') <> 'Y';


dbms_output.put_line( 'Raj' );

SELECT AGT_NM INTO v_AgentName FROM TAG WHERE AGT_ID = (Select a.data.RequestData.AgentCode 	FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID); 
SELECT PRODUCT_DESC INTO v_PlanName FROM PROD_TYPE_MASTER WHERE PRODUCT_STAT ='A'   AND TRANS_TYPE='I'   AND PRODUCT_CODE= (Select distinct a.data.RequestData.ProductType 	FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID
																									)	 ORDER BY PRODUCT_DESC ;
                                                                                                    dbms_output.put_line( 'Rajj' );
Select a.data.RequestData.PayInfo.PaymentType INTO v_PAYTYPE 	FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID;

                                       dbms_output.put_line( 'v_PAYTYPE ' );           
--IF (v_PAYTYPE = 2)
--THEN
--dbms_output.put_line( 'Insert v_DeptBranchCode into Check_Payment' );
SELECT DISTINCT  bm.BANK_CODE INTO v_DeptBranchCode from BANK_MASTER bm,BRANCH_BANK bb,BRANCHTABLE bt,bank_bsntype bsn
where bm.BANK_CODE=bb.BANK_CODE and bb.BRANCH_CODE=bt.BRANCH_CODE and bm.bank_code=bsn.bank_code and bb.BANK_STATUS='A' and bb.pay_type = '2' and bsn.bsntype_code='IND' AND bt.BRANCH_CODE = (Select distinct a.data.RequestData.ReceiptingBranchCode 	FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID
																									) order by bt.BRANCH_NAME fetch first row only;
              dbms_output.put_line( 'v_DeptBranchCode' );      
                                                                                                    
												     
SELECT COUNT(NVL(RWS_OCCUP_ID,null)) into v_count FROM INGENIUM_OCCUPATION_MASTER where ING_OCCUP_ID=(Select a.data.RequestData.ClientInfo[1].PROP_OCCUPATION FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID);

                dbms_output.put_line( 'v_count::'); 
                
IF(v_count = 0)

THEN

v_DescCode := null;

dbms_output.put_line( 'Inside If');

ELSE

SELECT RWS_OCCUP_ID into v_DescCode FROM INGENIUM_OCCUPATION_MASTER  where ING_OCCUP_ID=(Select a.data.RequestData.ClientInfo[1].PROP_OCCUPATION FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID) fetch first row only;
                                                                                
                                            dbms_output.put_line( 'v_DescCode::');
END IF;

/*IF (v_PAYTYPE = 5)
THEN
dbms_output.put_line( 'Insert v_DeptBranchCode into Draft_Payment' );
SELECT DISTINCT  bm.BANK_CODE INTO v_DeptBranchCode from BANK_MASTER bm,BRANCH_BANK bb,BRANCHTABLE bt,bank_bsntype bsn
where bm.BANK_CODE=bb.BANK_CODE and bb.BRANCH_CODE=bt.BRANCH_CODE and bm.bank_code=bsn.bank_code and bb.BANK_STATUS='A' and bb.pay_type = '5' and bsn.bsntype_code='IND' AND bt.BRANCH_CODE = (Select distinct a.data.RequestData.ReceiptingBranchCode 	FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID
																									) order by bt.BRANCH_NAME fetch first row only;

END IF;*/

dbms_output.put_line( 'Insert into Policy' );

Insert 
into policy 
( RECORD_NUMBER,
POLICY_NUMBER,
INSURED_NAME,
OWNER_NAME,
BRANCH_CODE,
BRANCH_NAME,
AGENT_CODE,
AGENT_NAME,
MAILING_NAME,
MAILING_ADD1,
MAILING_ADD2,
MAILING_ADD3,
MAILING_ADD4,
MAILING_ADD5,
ISSUE_DATE,
PROCESS_DATE,
RCPT_CLR_DT,
RCPT_STATUS,
USER_ID,
CLIENT_NUMBER,
ADDL_REFNUMBER,
BILL_NUMBER,
BILL_AMOUNT,
IP_MODE,
MAILING_AREA,
DEP_BANK_CODE,
BUSINESS_TYPE,
DEPT_TYPE,
PRODUCT_TYPE,
PAY_MODE,
ECS_OPT,
CLIENT_TYPE,
APPL_RCV_DT,
RCPT_EFF_DT,
PAYOR_NAME,
PAN_NO,
OR_NUM,
CONTACT_NO,
MODAL_PREM,
PLAN_NAME,
PAY_TERM,
ADVNCED_PREM,
PAYER_LAST_NAME,
OWNER_MID_NAME,
OWNER_LAST_NAME,
INSURED_LAST_NAME,
MODAL_PREM_TOTAL,
SUM_ASSURED,
BENEFIT_TERM,
UIN_LOGIN_DT,
PRODUCT_UIN,
PRAN_NIA,AUTO_RECEIPT,RECEIPT_STATUS)

SELECT 1 AS RECORD_NUMBER,
 a.data.RequestData.ApplicationNo AS POLICY_NUMBER,
CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('I') THEN 
	a.data.RequestData.ClientInfo[0].FirstName || ' ' || a.data.RequestData.ClientInfo[0].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('I') THEN 
 a.data.RequestData.ClientInfo[1].FirstName || ' ' || a.data.RequestData.ClientInfo[1].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('I') THEN
   a.data.RequestData.ClientInfo[2].FirstName || ' ' || a.data.RequestData.ClientInfo[2].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END AS INSURED_NAME,
 CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].FirstName || ' ' || a.data.RequestData.ClientInfo[0].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].FirstName || ' ' || a.data.RequestData.ClientInfo[1].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
   a.data.RequestData.ClientInfo[2].FirstName || ' ' || a.data.RequestData.ClientInfo[2].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END AS OWNER_NAME,
   a.data.RequestData.ReceiptingBranchCode AS BRANCH_CODE,
   a.data.RequestData.ReceiptingBranchName AS BRANCH_NAME,
   a.data.RequestData.AgentCode AS AGENT_CODE,
   v_AgentName AS AGENT_NAME,
   NULL AS MAILING_NAME,
	 CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address1 
   ELSE '' END AS MAILING_ADD1,
    CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address2 
   ELSE '' END AS MAILING_ADD2,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address3 
   ELSE '' END AS MAILING_ADD3,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].City
   ELSE '' END AS MAILING_ADD4,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Pin
   ELSE '' END AS MAILING_ADD5,
   TO_TIMESTAMP(a.data.RequestData.ApplRecvDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS ISSUE_DATE,
   TO_DATE(SUBSTR(a.data.RequestData.ProcessDate,0,10),'YYYY-MM-DD') AS PROCESS_DATE,
   TO_DATE(SUBSTR(a.data.RequestData.ProcessDate,0,10),'YYYY-MM-DD') AS RCPT_CLR_DT,
   'C' AS RCPT_STATUS,
   'INGRP2755' AS USER_ID,
   a.data.RequestData.ClientInfo[0].ClientNo AS CLIENT_NUMBER,
   a.data.RequestData.AdditionalRefNo AS ADDL_REFNUMBER,
   a.data.RequestData.Payinfo.BillNo AS BILL_NUMBER,
   a.data.RequestData.PayInfo.BillAmount AS BILL_AMOUNT,
    a.data.RequestData.IPMode AS IP_MODE,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address4
   ELSE '' END AS MAILING_AREA,
 v_DeptBranchCode AS DEP_BANK_CODE,
 'IND' AS BUSINESS_TYPE,
 a.data.RequestData.DepartmentType AS DEPT_TYPE,
 a.data.RequestData.ProductType AS PRODUCT_TYPE,
 a.data.RequestData.PayInfo.PayAddlInfo.PaymentMode AS PAY_MODE,
 a.data.RequestData.PayInfo.PayAddlInfo.PayMethod AS ECS_OPT,
 a.data.RequestData.PayInfo.PayAddlInfo.ClientType AS CLIENT_TYPE,
 TO_TIMESTAMP(a.data.RequestData.ApplRecvDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS APPL_RCV_DT,
 TO_TIMESTAMP(a.data.RequestData.PayInfo.EffectiveDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS RCPT_EFF_DT,
 CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].FirstName || ' ' || a.data.RequestData.ClientInfo[0].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].FirstName || ' ' || a.data.RequestData.ClientInfo[1].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
   a.data.RequestData.ClientInfo[2].FirstName || ' ' || a.data.RequestData.ClientInfo[2].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END AS PAYOR_NAME,
 a.data.RequestData.ClientInfo[0].PANNumber AS PAN_NO,
 v_OR_NUM AS OR_NUM,
 a.data.RequestData.AddressInfo[0].ContactNo AS CONTACT_NO,
 a.data.RequestData.PayInfo.ModalPremium AS MODAL_PREM,
 v_PlanName AS PLAN_NAME,
 NULL AS PAY_TERM,
 NULL AS ADVNCED_PREM,
 CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
   a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END AS PAYER_LAST_NAME,
 CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].MiddleName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].MiddleName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
  a.data.RequestData.ClientInfo[2].MiddleName
   ELSE ''   END AS OWNER_MID_NAME,
  CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
   a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END  AS OWNER_LAST_NAME,
  CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('I') THEN 
	a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('I') THEN 
 a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('I') THEN
   a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END  AS INSURED_LAST_NAME,
 NULL AS MODAL_PREM_TOTAL,
 a.data.RequestData.PayInfo.Sum_Assured AS SUM_ASSURED,
 NULL AS BENEFIT_TERM,
 NULL AS UIN_LOGIN_DT,
 a.data.RequestData.ProductUIN AS PRODUCT_UIN,
 NULL AS PRAN_NIA,
 'W' AS AUTO_RECEIPT,
 'FRESH' AS RECEIPT_STATUS


FROM     T_JSON_OFFLINE_PAY a
where APP_NO = IN_APP_NO  and REQUEST_ID=IN_RequestID ;
--AND DT_CREATE='2022-02-07';
dbms_output.put_line( 'Insert into Policy successfully' );

--COMMIT;
dbms_output.put_line( 'Insert into Payment' );
/* SELECT DEPT_TYPE_NAME INTO v_departmentTypeName FROM DEPT_TYPE_MASTER 
WHERE BSNTYPE_CODE = 'IND' and DEPT_TYPE_CODE = (Select distinct a.data.RequestData.DepartmentType 
																									FROM T_JSON_OFFLINE_PAY a
																									WHERE APP_NO = IN_APP_NO
																									AND   REQUEST_ID = IN_RequestID--AND DT_CREATE='2022-02-07';
																									);
 */


INSERT INTO payment
(
	RECORD_NUMBER,
  POLICY_NUMBER,
  TRANS_TYPE,
  PAY_TYPE,
  AMOUNT1,
  AMOUNT2,
  AMOUNT3,
  AMOUNT4,
  AMOUNT5,
  PARTCODE1,
  PARTCODE2,
  PARTCODE3,
  PARTCODE4,
  PARTCODE5,
  TOTAL_AMOUNT,
  EFF_DATE,
  PR_NUMBER,
  PR_DATE,
  OR_NUMBER,
  CURRENCY,
  RATE,
  CURR_AMOUNT,
  REMARKS,
  SPOILED_FLAG,
  PARTICULAR1,
  PARTICULAR2,
  PARTICULAR3,
  PARTICULAR4,
  PARTICULAR5,
  REC_OPTION,
  STAX_AMT,
  CS_AMT1,
  PREV_UPDT_TS,
  TRANS_OPTION,
  UWREQ,
  PREMCHANGEREASON,
  GSTFLAG,
  PAYMENT_GATEWAY,
  PAYMENT_MODE
)
SELECT 1 AS RECORD_NUMBER,
		a.data.RequestData.ApplicationNo AS POLICY_NUMBER,
       'I' AS TRANS_TYPE,
      -- a.data.RequestData.PaymentType AS PAY_TYPE,
      a.data.RequestData.PayInfo.PaymentType AS PAY_TYPE,
       a.data.RequestData.PayInfo.PayAddlInfo.MultiplePayments.TotalAmount AS AMOUNT1,
       0 AS AMOUNT2,
       0 AS AMOUNT3,
       0 AS AMOUNT4,
       0 AS AMOUNT5,
       a.data.RequestData.PayInfo.PayAddlInfo.MultiplePayments.Purpose AS PARTCODE1,
       '-' AS PARTCODE2,
       '-' AS PARTCODE3,
       '-' AS PARTCODE4,
       '-' AS PARTCODE5,
        a.data.RequestData.PayInfo.PayAddlInfo.MultiplePayments.TotalAmount AS TOTAL_AMOUNT,
       TO_TIMESTAMP(a.data.RequestData.PayInfo.EffectiveDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS EFF_DATE,
       NULL AS PR_NUMBER,
       NULL AS PR_DATE,
       v_OR_NUM AS OR_NUMBER,
       NULL AS CURRENCY,
       NULL AS RATE,
       NULL AS CURR_AMOUNT,
       a.data.RequestData.Remarks AS REMARKS,
       NULL AS SPOILED_FLAG,
       'Deposit Application Under Consideration' AS PARTICULAR1,
        '---------------------------------------' AS PARTICULAR2,
        '---------------------------------------' AS PARTICULAR3,
        '---------------------------------------' AS PARTICULAR4,
        '---------------------------------------' AS PARTICULAR5,
       0 AS REC_OPTION,
       0 AS STAX_AMT,
       0 AS CS_AMT1,
      NULL AS PREV_UPDT_TS,
       NULL AS TRANS_OPTION,
       NULL AS UWREQ,
       NULL AS PREMCHANGEREASON,
       NULL AS GSTFLAG,
       NULL AS NPAYMENT_GATEWAY,
       a.data.RequestData.PayInfo.PayAddlInfo.PaymentMode AS PAYMENT_MODE
FROM T_JSON_OFFLINE_PAY a
WHERE APP_NO = IN_APP_NO 
AND   REQUEST_ID = IN_RequestID;
--AND DT_CREATE='2022-02-07';
dbms_output.put_line( 'Insert into Payment successfully' );
--COMMIT;
IF (v_PAYTYPE = 2)
THEN
dbms_output.put_line( 'Insert into Check_Payment' );
INSERT INTO check_payment
( RECORD_NUMBER,
  POLICY_NUMBER,
  DRAWEE_BANK,
  CHECK_TYPE,
  CHECK_NUMBER,
  CHECK_DATE,
  CHECK_AMOUNT,
  CHECK_REMARKS,
  BANK_CODE,
  BANK_CODE2,
  CHECK_TYPE2,
  CHECK_NUMBER2,
  CHECK_DATE2,
  CHECK_AMOUNT2,
  DRAWEE_BANK2,
  BANK_CODE3,
  CHECK_TYPE3,
  CHECK_NUMBER3,
  CHECK_DATE3,
  CHECK_AMOUNT3,
  DRAWEE_BANK3,
  CHECK1_MICR_TYPE,
  CHECK2_MICR_TYPE,
  CHECK3_MICR_TYPE,
  CHQ1_ACT_TYPE,
  CHQ2_ACT_TYPE,
  CHQ3_ACT_TYPE,
  OR_NUM,
  DEP_SLIP_NO,
  DEP_SLIP_NO2,
  DEP_SLIP_NO3,
  PREV_UPDT_TS,
  CHQ_USER_ID,
  CHQ_PROCESS_DT,
  IS_FINAL_PIS
)

SELECT 1 AS RECORD_NUMBER,
	 a.data.RequestData.ApplicationNo AS POLICY_NUMBER,
  a.data.RequestData.PayInfo.PayAddlInfo.BankName AS DRAWEE_BANK,
  a.data.RequestData.PayInfo.PayAddlInfo.InstrumentType AS CHECK_TYPE,
  a.data.RequestData.PayInfo.PayAddlInfo.InstrumentNo AS CHECK_NUMBER,
  TO_TIMESTAMP(a.data.RequestData.PayInfo.PayAddlInfo.InstrumentDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS CHECK_DATE,
   a.data.RequestData.PayInfo.PayAddlInfo.InstrumentAmount AS CHECK_AMOUNT,
  NULL AS CHECK_REMARKS,
  a.data.RequestData.PayInfo.PayAddlInfo.BankCode AS BANK_CODE,
 NULL AS  BANK_CODE2,
 NULL AS CHECK_TYPE2,
 NULL AS CHECK_NUMBER2,
  NULL AS CHECK_DATE2,
  NULL AS CHECK_AMOUNT2,
  NULL AS DRAWEE_BANK2,
  NULL AS BANK_CODE3,
  NULL AS CHECK_TYPE3,
  NULL AS CHECK_NUMBER3,
  NULL AS CHECK_DATE3,
  NULL AS CHECK_AMOUNT3,
  NULL AS DRAWEE_BANK3,
  1 AS CHECK1_MICR_TYPE,
  NULL AS CHECK2_MICR_TYPE,
  NULL AS CHECK3_MICR_TYPE,
  a.data.RequestData.PayInfo.PayAddlInfo.AccountType AS CHQ1_ACT_TYPE,
  NULL AS CHQ2_ACT_TYPE,
  NULL AS CHQ3_ACT_TYPE,
  v_OR_NUM AS OR_NUM,
  NULL AS DEP_SLIP_NO,
  NULL AS DEP_SLIP_NO2,
  NULL AS DEP_SLIP_NO3,
  NULL PREV_UPDT_TS,
  NULL CHQ_USER_ID,
  TO_TIMESTAMP(a.data.RequestData.ProcessDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS CHQ_PROCESS_DT,
  NULL AS IS_FINAL_PIS

FROM T_JSON_OFFLINE_PAY a
WHERE APP_NO = IN_APP_NO 
AND   REQUEST_ID = IN_RequestID;
--AND DT_CREATE='2022-02-07';

dbms_output.put_line( 'Insert into Check_Payment successfully' );

END IF;
--COMMIT;


IF (v_PAYTYPE = 5)
THEN
dbms_output.put_line( 'Insert into Draft_Payment' );
INSERT INTO DRAFT_PAYMENT(
POLICY_NUMBER,
RECORD_NUMBER,
DRAWEE_BANK,
DRAFT_TYPE,
DRAFT_NUMBER,
DRAFT_DATE,
DRAFT_AMOUNT,
BANK_CODE,
BANK_CODE2,
DRAFT_TYPE2,
DRAFT_NUMBER2,
DRAFT_DATE2,
DRAFT_AMOUNT2,
DRAWEE_BANK2,
BANK_CODE3,
DRAFT_TYPE3,
DRAFT_DATE3,
DRAFT_NUMBER3,
DRAFT_AMOUNT3,
DRAWEE_BANK3,
DRAFT1_ACT_TYPE,
DRAFT2_ACT_TYPE,
DRAFT3_ACT_TYPE,
OR_NUM ,
DFT_USER_ID,
DFT_PROCESS_DT  )     

SELECT 
	 a.data.RequestData.ApplicationNo AS POLICY_NUMBER,
   1 AS RECORD_NUMBER,
  a.data.RequestData.PayInfo.PayAddlInfo.BankName AS DRAWEE_BANK,
  a.data.RequestData.PayInfo.PayAddlInfo.InstrumentType AS DRAFT_TYPE,
  a.data.RequestData.PayInfo.PayAddlInfo.InstrumentNo AS DRAFT_NUMBER,
  TO_TIMESTAMP(a.data.RequestData.PayInfo.PayAddlInfo.InstrumentDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS DRAFT_DATE,
   a.data.RequestData.PayInfo.PayAddlInfo.InstrumentAmount AS DRAFT_AMOUNT,
  a.data.RequestData.PayInfo.PayAddlInfo.BankCode AS BANK_CODE,
 NULL AS  BANK_CODE2,
 NULL AS DRAFT_TYPE2,
 NULL AS DRAFT_NUMBER2,
  NULL AS DRAFT_DATE2,
  NULL AS DRAFT_AMOUNT2,
  NULL AS DRAWEE_BANK2,
  NULL AS BANK_CODE3,
  NULL AS DRAFT_TYPE3,
  NULL AS DRAFT_NUMBER3,
  NULL AS DRAFT_DATE3,
  NULL AS DRAFT_AMOUNT3,
  NULL AS DRAWEE_BANK3,
  a.data.RequestData.PayInfo.PayAddlInfo.AccountType AS DRAFT1_ACT_TYPE,
  NULL AS DRAFT2_ACT_TYPE,
  NULL AS DRAFT3_ACT_TYPE,
  v_OR_NUM AS OR_NUM,
  NULL DFT_USER_ID,
  TO_TIMESTAMP(a.data.RequestData.ProcessDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS DFT_PROCESS_DT

FROM T_JSON_OFFLINE_PAY a
WHERE APP_NO = IN_APP_NO 
AND   REQUEST_ID = IN_RequestID;
--AND DT_CREATE='2022-02-07';

dbms_output.put_line( 'Insert into Draft_Payment successfully' );

END IF;
--COMMIT;



dbms_output.put_line( 'Insert into App_Details' );
Insert into app_details
(
    APP_NUMBER,
    INSURED_NAME,
    OWNER_NAME,
    ANN_PREMIUM,
    SUM_ASSURED,
    AGENT_CODE,
    MAILING_NAME,
    MAILING_ADD1,
    MAILING_ADD2,
    MAILING_ADD3,
    MAILING_ADD4,
    MAILING_ADD5,
    MAILING_AREA,
    BRANCH_CODE,
    USER_ID,
    PROCESS_DATE,
    BUSINESS_TYPE,
    DEPT_TYPE,
    PRODUCT_TYPE,
    PAY_MODE,
    APPL_RCV_DT,
    APP_STATUS,
    ECS_OPT,
    CLIENT_TYPE,
    TPDBRANCH_CODE,
    TPDAGENT_CODE,
    CUST_ID,
    UNITMGR_CODE,
    SALESMGR_CODE,
    AREASMGR_CODE,
    ZONALSMGR_CODE,
    AGE_PROOF_CODE,
    ID_PROOF_CODE,
    ADDR_PROOF_CODE,
    INCOME_PROOF_CODE,
    PREV_POL_NUMBER,
    QUES_DTLS,
    REQT_DTLS,
    PAY_PERIOD,
    REJECTED_BY,
    REJECTED_DT,
    REJECTED_RESN,
    APP_RCPT_DT,
    SRC_BRANCH_CODE,
    DESP_FLAG,
    DESP_DATE,
    HRESN_CD,
    PREV_UPDATED_BY,
    PREV_UPDATED_DT,
    PAYOR_NAME,
    PAN_NO,
    PAN_PROOF_CODE,
    PREV_UPDT_TS,
    APP_LOGIN_BY,
    APP_LOGIN_DT,
    APP_APPROVED_BY,
    APP_APPROVED_DT,
    APPROVAL_REMARK,
    EXTRA_PREM,
    INS_DOB,
    INS_AGE,
    INS_GENDER,
    REMARKS,
    QC_QUES_DTLS,
    QC_REMARK,
    CONTACT_NO,
    NOMINEE_NAME,
    NOMINEE_REL,
    ENHCD_SA,
    BNYFT_PRD,
    ENHCD_SVNG_PRM,
    BASIC_SA,
    BASIC_PREM,
    ENHCD_SA_PREM,
    RIDER_PREM,
    AGT_CATEGORY,
    MICR_CODE,
    CAMS_APP_RCVD_DT,
    SMOKER_STATUS,
    FORM60,
    ACCT_NUM,
    PREV_POL_NUM,
    PREV_INSURD_NAME,
    PREV_POLL_ISS_EFDT,
    PREV_SUM_ASURD,
    PREV_BENFT_PRD,
    PREV_PAY_PRD,
    VERIFIER_CD,
    TELE_CD,
    CA_REF1,
    DMFLAG,
    UPSEL_ID,
    SD_ID,
    SD_APRVL_MAIL_FLG,
    SD_REG_MAIL_FLG,
    SEL_INVS,
    SEL_INVS_BWM,
    SEL_TR_DT,
    PIVC_REQ_EXT_FLAG,
    ECS_END_DT,
    ECS_TERM_DT,
    EXCEPTION_RECEIVED,
    INITIAL_CHQ_ACC_NO,
    EAPP_IMPORT_DT,
    PIVC_FLAG,
    RECIDENT_NO,
    SPSIGN_STATUS,
    MODAL_PREM,
    SEL_INVS_WAP,
    SEL_INVS_BEM,
    SCRATCH_NO,
    SCRATCH_CDIG1,
    SCRATCH_CDIG,
    CUST_JN_DEC_FRM,
    SUS_BR_EXT_FLAG,
    PREFERED_LANGUAGE,
    OTHER_LANGUAGE,
    ANNUITY_OPT,
    ANNUITY_MODE,
    ANNUITY_AMT,
    SCHEME_NO,
    SERVICE_TAX,
    ILLUS_UID,
    MHR_DT,
    MHR_CLT_MET_DT,
    MHR_CLT_MET_TIME,
    MHR_RESN_NOT_ACPT,
    SUSP_APP_STATUS,
    DEP_BANK_CODE,
    JDF_REQ_EXT_FLAG,
    SEL_INVS_WMP,
    SEL_INVS_BWA,
    COMBO_PRIM_APP,
    COMBO_QUESTION,
    COMBO_REQ_EXT_FLAG,
    OWNER_GENDER,
    CAMPAIGN_TYPE,
    CUSTOMER_RELATION,
    LEAD_ID,
    FT_TYPE,
    BDMFLAG,
    NEFT_CASE,
    IFSC_CD,
    BNK_NM,
    BNK_BR_NM,
    BNK_MICR_CD,
    NEFT_ACCT_NUM,
    NEFT_ACCT_TYP_CD,
    NEFT_REQ_FLAG,
    CMB_PAYOUT,
    CMB_FE_FLAG,
    CMB_CLIENT_CRN,
    COMBO_PLAN_TYPE,
    EIAACCNUM,
    EIA_STATUS,
    EIAFLAG,
    EIASOURCE,
    EIA_REQ_EXT_FLAG,
    SEL_INVS_BFE,
    PAYOR_PAN_NO,
    ISOWNER_PAYER_SAME,
    SOURCE_TYPE,
    CATEGORY,
    OTHER_CAT,
    CLUSTER_NOM_ID,
    OTHER_THAN_BSLI_SA,
    NOMINEE_AGE,
    NOMINEE_DOB,
    OWN_MAILING_AREA,
    OWN_AGE,
    OWN_DOB,
    IS_EXIST_SA_O_COMP,
    MAILING_ADD1_PER,
    MAILING_ADD2_PER,
    MAILING_ADD3_PER,
    MAILING_ADD4_PER,
    MAILING_ADD5_PER,
    MAILING_AREA_PER,
    ABG_EMPLOYEE,
    PROP_RELATION,
    LI_RELATION,
    PAYOR_RELATION,
    LI_OCCUPATION,
    LI_ANN_INCOME,
    LI_MARITAL_STAT,
    PROP_OCCUPATION,
    PROP_ANN_INCOME,
    PROP_MARITAL_STAT,
    PROP_EMAIL,
    NATIONALITY,
    POL_TYPE,
    IS_MULTI_UID,
    ADD_RSA,
    CI_RSA,
    SC_RSA,
    HC_RSA,
    WOP_RSA,
    PRIM_UID,
    IS_ADDRESS_SAME,
    LI_LAST_NAME,
    INC_LEVEL,
    OWNER_LAST_NAME,
    PAYOR_LAST_NAME,
    ISOWNER_INSURED_SAME,
    OWNER_MID_NAME,
    INSURED_MID_NAME,
    E_INS_ACT_NO,
    EPOL,
    IS_SUSPECT,
    ISEIAADDSAME,
    ISICHAMPDATA,
    PIVC_UPDATED_BY,
    PIVC_UPDATED_DT,
    REC_COMMENTS,
    REC_WITH_PEND_PEQ,
    REC_WITH_PEND_RMRK,
    SEL_INVS_EPP,
    IR_CODE,
    COMBO_PROD_CAT,
    ISPCTDATA,
    PROSPECT_ID,
    ADV_OWNER_MOB_FLAG,
    ADV_OWNER_RELATION,
    SEL_INVS_WAS,
    PLAN_SAR_OPTION,
    SEL_INVS_WMX,
    APP_VERSION,
    ISNOMMINOR,
    FATCA_REQ_FLAG,
    NEFT_EXT_FLAG,
    ADB_RSA,
    INDEX_EXTRACT_FLAG,
    INDEX_EXTRACT_DT,
    EXC_APPR_RCVD_FRM,
    SEL_INV_WAE,
    ASPIRE_OPTION,
    SEL_INVS_WAE,
    ACCOUNT_NUMBER,
    --CKYC,
    BENEFIT_OPTION,
    D_SOURCE,
    EAPP_SAL_DEDUCTION,
    CUSTOMER_TYPE,
    OR_ING_UPDATED_FLAG,
    OR_ING_UPDATED_DT,
    POL_REJ_REASN_CD,
    COUNTRY_NAME,
    --TAX_RESIDNT_NUMBER,
    CD_CASE_FLAG,
    INCOMEBNTERM,
    INSURED_TYPE,
    CRN,
    BSLI_REP_CD,
    SOURCE_ID,
    ING_CHANNEL_CODE,
    --ING_VERTICAL_FLAG,
    AAN,
    DMG_FLAG,
    CREDIT_CARD_NO,
    HDFC_LG_CODE,
    IS_REQ97,
    PUR_INS,
    OWNER_MAIDEN_NAME,
    OWNER_MOTHER_NAME,
    INS_MAIDEN_NAME,
    INS_MOTHER_NAME,
    COMM_ADDR_TYPE,
    PER_ADDR_TYPE,
    DEFERMENT_PERIOD,
    INCOME_BENEFIT_PERIOD,
    INSTALMENTPREMIUM,
    MODALBASICPREMIUM,
    GST,
    ANNUALPREM_WITHGST,
    ANNUALPREM_WITHOUTGST,
    MODAL_PREMIUM,
    TRCP2_FLAG,
    COMBO_ID,
    COMBO_NAME,
    COMBO_TYPE,
    MULTI_RECEIPT_FLAG,
    IS_PRIMARY_APPLICATION,
    PRODUCT_UIN,
    FT_EXTRACT_STATUS,
    FT_EXTRACTED_DATE,
    UIN_LOGIN_DT,
    WIN_BACK_OPTION,
    PIVC_ING_INSR_FLAG,
    GRN_CHNL_FLG,
    EAPP_ELD_FLG,
    GRN_CHNL_DESC,
    PIVC_ING_INSR_TIMESTAMP,
    REV_TPDAGENT_CODE,
    IS_INTERNAL_FT,
    SP_MOB_NO,
    SP_EMAIL_ID,
    RO_MOB_NO,
    RO_EMAIL_ID,
    FORM_FULFILMENT_LINK,
    PIVC_ELLIGIBILITY,
    FT_FLAG,
    RO_NAME,
    INSURED_EMAIL_ID,
    PROP_MOB_NO,
    SR_CITIZEN_FLAG,
    MARGINAL_INCOME_CASE,
    EMI,
    ANNUAL_INCOME,
    ANNUAL_PREMIUM,
    INSTA_STATUS,
    MASTER_POLICY_NO,
    MASTER_POLICYHOLDER_NAME,
    PAYMENT_RECEIVED_DATE,
    --INSURED_MOBILE_NO,
    LEAP_HEADER_ENTRY
)
SELECT  a.data.RequestData.ApplicationNo AS APP_NUMBER,
				CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('I') THEN 
					a.data.RequestData.ClientInfo[0].FirstName || ' ' || a.data.RequestData.ClientInfo[0].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[0].LastName
				 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('I') THEN 
				 a.data.RequestData.ClientInfo[1].FirstName || ' ' || a.data.RequestData.ClientInfo[1].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[1].LastName
				  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('I') THEN
				   a.data.RequestData.ClientInfo[2].FirstName || ' ' || a.data.RequestData.ClientInfo[2].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[2].LastName
				   ELSE ''   END AS INSURED_NAME,
				 CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
					a.data.RequestData.ClientInfo[0].FirstName || ' ' || a.data.RequestData.ClientInfo[0].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[0].LastName
				 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
				 a.data.RequestData.ClientInfo[1].FirstName || ' ' || a.data.RequestData.ClientInfo[1].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[1].LastName
				  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
				   a.data.RequestData.ClientInfo[2].FirstName || ' ' || a.data.RequestData.ClientInfo[2].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[2].LastName
				   ELSE ''   END AS OWNER_NAME,
            a.data.RequestData.Payinfo.AnnualPremium AS ANN_PREMIUM,
            a.data.RequestData.PayInfo.Sum_Assured AS SUM_ASSURED,
       		a.data.RequestData.AgentCode AS AGENT_CODE,
       		NULL AS MAILING_NAME,
 					CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address1 
   ELSE '' END AS MAILING_ADD1,
    CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address2 
   ELSE '' END AS MAILING_ADD2,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Address3 
   ELSE '' END AS MAILING_ADD3,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].City 
   ELSE '' END AS MAILING_ADD4,
   CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('I') THEN
   a.data.RequestData.AddressInfo[0].Pin 
   ELSE '' END AS MAILING_ADD5,
					 a.data.RequestData.Pin AS MAILING_AREA,
						a.data.RequestData.ReceiptingBranchCode AS BRANCH_CODE,
   				'INGRP2755' AS USER_ID,
    TO_DATE(SUBSTR(a.data.RequestData.ProcessDate,0,10),'YYYY-MM-DD') AS PROCESS_DATE,
    'IND' AS BUSINESS_TYPE,
    a.data.RequestData.DepartmentType AS DEPT_TYPE,
    a.data.RequestData.ProductType AS PRODUCT_TYPE,
    a.data.RequestData.PayInfo.PayAddlInfo.PaymentMode AS PAY_MODE,
    TO_TIMESTAMP(a.data.RequestData.ApplRecvDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS APPL_RCV_DT,
    'A' AS APP_STATUS,
    a.data.RequestData.PayInfo.PayAddlInfo.PayMethod AS ECS_OPT,
    a.data.RequestData.PayInfo.PayAddlInfo.ClientType AS CLIENT_TYPE,
    NULL AS TPDBRANCH_CODE,
    NULL AS TPDAGENT_CODE,
    NULL AS CUST_ID,
    NULL AS UNITMGR_CODE,
    NULL AS SALESMGR_CODE,
    NULL AS AREASMGR_CODE,
    NULL AS ZONALSMGR_CODE,
    NULL AS AGE_PROOF_CODE,
    NULL AS ID_PROOF_CODE,
    NULL AS ADDR_PROOF_CODE,
    NULL AS INCOME_PROOF_CODE,
    NULL AS PREV_POL_NUMBER,
    NULL AS QUES_DTLS,
    NULL AS REQT_DTLS,
    a.data.RequestData.PayInfo.PayAddlInfo.Pay_Period AS PAY_PERIOD,
    NULL AS REJECTED_BY,
    NULL AS REJECTED_DT,
    NULL AS REJECTED_RESN,
    TO_TIMESTAMP(a.data.RequestData.ApplRecvDate,'YYYY-MM-DD HH24:MI:SS:FF9') AS APP_RCPT_DT,
    a.data.RequestData.ReceiptingBranchCode AS SRC_BRANCH_CODE,
    NULL AS DESP_FLAG,
    NULL AS DESP_DATE,
    NULL AS HRESN_CD,
    NULL AS PREV_UPDATED_BY,
    NULL AS PREV_UPDATED_DT,
    CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].FirstName || ' ' || a.data.RequestData.ClientInfo[0].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].FirstName || ' ' || a.data.RequestData.ClientInfo[1].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
   a.data.RequestData.ClientInfo[2].FirstName || ' ' || a.data.RequestData.ClientInfo[2].MiddleName|| ' ' ||a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END  AS PAYOR_NAME,
    CASE WHEN a.data.RequestData.PANNumber.ClientCategory IN ('I') THEN
   a.data.RequestData.PANNumber 
   ELSE '' END  AS PAN_NO,
    NULL AS PAN_PROOF_CODE,
    NULL AS PREV_UPDT_TS,
    NULL AS APP_LOGIN_BY,
    NULL AS APP_LOGIN_DT,
    NULL AS APP_APPROVED_BY,
    NULL AS APP_APPROVED_DT,
    NULL AS APPROVAL_REMARK,
	NULL AS EXTRA_PREM,
    TO_DATE(SUBSTR(a.data.RequestData.ClientInfo[0].INS_DOB,0,10),'YYYY-MM-DD') AS INS_DOB,
    a.data.RequestData.ClientInfo[0].INS_AGE AS INS_AGE,
    a.data.RequestData.ClientInfo[0].INS_GENDER AS INS_GENDER,
    NULL AS REMARKS,
    NULL AS QC_QUES_DTLS,
    NULL AS QC_REMARK,
    a.data.RequestData.AddressInfo[0].ContactNo AS CONTACT_NO,
    a.data.RequestData.NOMINEE_NAME AS NOMINEE_NAME,
    NULL AS NOMINEE_REL,
    NULL AS ENHCD_SA,
    a.data.RequestData.BNYFT_PRD AS  BNYFT_PRD,
    NULL AS ENHCD_SVNG_PRM,
   NULL AS BASIC_SA,
    NULL AS BASIC_PREM,
    NULL AS ENHCD_SA_PREM,
    NULL AS RIDER_PREM,
    NULL AS AGT_CATEGORY,
    NULL AS MICR_CODE,
    NULL AS CAMS_APP_RCVD_DT,
    NULL AS SMOKER_STATUS,
    NULL AS FORM60,
    NULL AS ACCT_NUM,
    NULL AS PREV_POL_NUM,
    NULL AS PREV_INSURD_NAME,
    NULL AS PREV_POLL_ISS_EFDT,
    NULL AS PREV_SUM_ASURD,
    NULL AS PREV_BENFT_PRD,
    NULL AS PREV_PAY_PRD,
    NULL AS VERIFIER_CD,
    NULL AS TELE_CD,
    NULL AS CA_REF1,
    NULL AS DMFLAG,
    NULL AS UPSEL_ID,
    NULL AS SD_ID,
    NULL AS SD_APRVL_MAIL_FLG,
    NULL AS SD_REG_MAIL_FLG,
    NULL AS SEL_INVS,
    NULL AS SEL_INVS_BWM,
    NULL AS SEL_TR_DT,
    NULL AS PIVC_REQ_EXT_FLAG,
    NULL AS ECS_END_DT,
    NULL AS ECS_TERM_DT,
    NULL AS EXCEPTION_RECEIVED,
    NULL AS INITIAL_CHQ_ACC_NO,
    TO_DATE(SUBSTR(a.data.RequestTS,0,10),'YYYY-MM-DD') AS EAPP_IMPORT_DT,
    NULL AS PIVC_FLAG,
    NULL AS RECIDENT_NO,
    NULL AS SPSIGN_STATUS,
    a.data.RequestData.PayInfo.ModalPremium AS MODAL_PREM,
    NULL AS SEL_INVS_WAP,
    NULL AS SEL_INVS_BEM,
    NULL AS SCRATCH_NO,
    NULL AS SCRATCH_CDIG1,
    NULL AS SCRATCH_CDIG,
    NULL AS CUST_JN_DEC_FRM,
    NULL AS SUS_BR_EXT_FLAG,
    a.data.RequestData.Preferred_Language AS PREFERED_LANGUAGE,
    NULL AS OTHER_LANGUAGE,
    NULL AS ANNUITY_OPT,
    NULL AS ANNUITY_MODE,
    NULL AS ANNUITY_AMT,
    NULL AS SCHEME_NO,
    NULL AS SERVICE_TAX,
    NULL AS ILLUS_UID,
    NULL AS MHR_DT,
    NULL AS MHR_CLT_MET_DT,
    NULL AS MHR_CLT_MET_TIME,
    NULL AS MHR_RESN_NOT_ACPT,
    NULL AS SUSP_APP_STATUS,
    v_DeptBranchCode AS DEP_BANK_CODE,
    NULL AS JDF_REQ_EXT_FLAG,
    NULL AS SEL_INVS_WMP,
    NULL AS SEL_INVS_BWA,
    NULL AS COMBO_PRIM_APP,
    NULL AS COMBO_QUESTION,
    NULL AS COMBO_REQ_EXT_FLAG,
    a.data.RequestData.ClientInfo[1].PROP_GENDER AS OWNER_GENDER,
    NULL AS CAMPAIGN_TYPE,
    NULL AS CUSTOMER_RELATION,
    NULL AS LEAD_ID,
    a.data.RequestData.FT_Type AS FT_TYPE,
    'N' AS BDMFLAG,
    NULL AS NEFT_CASE,
    NULL AS IFSC_CD,
    NULL AS BNK_NM,
    NULL AS BNK_BR_NM,
    NULL AS BNK_MICR_CD,
    NULL AS NEFT_ACCT_NUM,
    NULL AS NEFT_ACCT_TYP_CD,
    NULL AS NEFT_REQ_FLAG,
    NULL AS CMB_PAYOUT,
    NULL AS CMB_FE_FLAG,
    NULL AS CMB_CLIENT_CRN,
    NULL AS COMBO_PLAN_TYPE,
    NULL AS EIAACCNUM,
    NULL AS EIA_STATUS,
    NULL AS EIAFLAG,
    NULL AS EIASOURCE,
    NULL AS EIA_REQ_EXT_FLAG,
    NULL AS SEL_INVS_BFE,
    NULL AS PAYOR_PAN_NO,
    NULL AS ISOWNER_PAYER_SAME,
    NULL AS SOURCE_TYPE,
    NULL AS CATEGORY,
    NULL AS OTHER_CAT,
    NULL AS CLUSTER_NOM_ID,
    NULL AS OTHER_THAN_BSLI_SA,
    NULL AS NOMINEE_AGE,
    NULL AS NOMINEE_DOB,
    NULL AS OWN_MAILING_AREA,
    a.data.RequestData.ClientInfo[1].PROP_AGE  AS OWN_AGE,
    TO_DATE(SUBSTR(a.data.RequestData.ClientInfo[1].PROP_DOB,0,10),'YYYY-MM-DD') AS OWN_DOB,
    NULL AS IS_EXIST_SA_O_COMP,
    NULL AS MAILING_ADD1_PER,
    NULL AS MAILING_ADD2_PER,
    NULL AS MAILING_ADD3_PER,
    NULL AS MAILING_ADD4_PER,
    NULL AS MAILING_ADD5_PER,
    NULL AS MAILING_AREA_PER,
    NULL AS ABG_EMPLOYEE,
    NULL AS PROP_RELATION,
    NULL AS LI_RELATION,
    NULL AS PAYOR_RELATION,
    NULL AS LI_OCCUPATION,
    NULL AS LI_ANN_INCOME,
    NULL AS LI_MARITAL_STAT,
    v_DescCode AS PROP_OCCUPATION,
    a.data.RequestData.ClientInfo[1].PROP_ANNUAL_INCOME AS PROP_ANN_INCOME,
    NULL AS PROP_MARITAL_STAT,
    CASE WHEN a.data.RequestData.AddressInfo[0].ClientCategory IN ('P') THEN
   a.data.RequestData.AddressInfo[0].EmailId 
    WHEN a.data.RequestData.AddressInfo[1].ClientCategory IN ('P') THEN
   a.data.RequestData.AddressInfo[1].EmailId 
   ELSE '' END AS PROP_EMAIL,
    NULL AS NATIONALITY,
    NULL AS POL_TYPE,
    NULL AS IS_MULTI_UID,
    NULL AS ADD_RSA,
    NULL AS CI_RSA,
    NULL AS SC_RSA,
    NULL AS HC_RSA,
    NULL AS WOP_RSA,
    NULL AS PRIM_UID,
    NULL AS IS_ADDRESS_SAME,
    NULL AS LI_LAST_NAME,
    NULL AS INC_LEVEL,
    CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].LastName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].LastName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
   a.data.RequestData.ClientInfo[2].LastName
   ELSE ''   END AS OWNER_LAST_NAME,
    NULL AS PAYOR_LAST_NAME,
    NULL AS ISOWNER_INSURED_SAME,
    CASE WHEN a.data.RequestData.ClientInfo[0].ClientCategory IN ('P') THEN 
	a.data.RequestData.ClientInfo[0].MiddleName
 WHEN a.data.RequestData.ClientInfo[1].ClientCategory IN ('P') THEN 
 a.data.RequestData.ClientInfo[1].MiddleName
  WHEN a.data.RequestData.ClientInfo[2].ClientCategory IN ('P') THEN
  a.data.RequestData.ClientInfo[2].MiddleName
   ELSE '' END AS OWNER_MID_NAME,
    NULL AS INSURED_MID_NAME,
    NULL AS E_INS_ACT_NO,
    NULL AS EPOL,
    NULL AS IS_SUSPECT,
    NULL AS ISEIAADDSAME,
    NULL AS ISICHAMPDATA,
    NULL AS PIVC_UPDATED_BY,
    NULL AS PIVC_UPDATED_DT,
    NULL AS REC_COMMENTS,
    NULL AS REC_WITH_PEND_PEQ,
    NULL AS REC_WITH_PEND_RMRK,
    NULL AS SEL_INVS_EPP,
    NULL AS IR_CODE,
    NULL AS COMBO_PROD_CAT,
    NULL AS ISPCTDATA,
    NULL AS PROSPECT_ID,
    NULL AS ADV_OWNER_MOB_FLAG,
    NULL AS ADV_OWNER_RELATION,
    NULL AS SEL_INVS_WAS,
    NULL AS PLAN_SAR_OPTION,
    NULL AS SEL_INVS_WMX,
    NULL AS APP_VERSION,
    NULL AS ISNOMMINOR,
    NULL AS FATCA_REQ_FLAG,
    NULL AS NEFT_EXT_FLAG,
    NULL AS ADB_RSA,
    NULL AS INDEX_EXTRACT_FLAG,
    NULL AS INDEX_EXTRACT_DT,
    NULL AS EXC_APPR_RCVD_FRM,
    NULL AS SEL_INV_WAE,
    NULL AS ASPIRE_OPTION,
    NULL AS SEL_INVS_WAE,
    NULL AS ACCOUNT_NUMBER,
    --NULL AS CKYC,
    NULL AS BENEFIT_OPTION,
    a.data.RequestSource AS D_SOURCE,
    NULL AS EAPP_SAL_DEDUCTION,
    NULL AS CUSTOMER_TYPE,
    NULL AS OR_ING_UPDATED_FLAG,
    NULL AS OR_ING_UPDATED_DT,
    NULL AS POL_REJ_REASN_CD,
    NULL AS COUNTRY_NAME,
    --NULL AS TAX_RESIDNT_NUMBER,
    NULL AS CD_CASE_FLAG,
    NULL AS INCOMEBNTERM,
    NULL AS INSURED_TYPE,
    NULL AS CRN,
    NULL AS BSLI_REP_CD,
    a.data.RequestData.Source_Identification_Tag AS SOURCE_ID,
    a.data.RequestData.Vertical_Channel AS ING_CHANNEL_CODE,
    --NULL AS ING_VERTICAL_FLAG,
    NULL AS AAN,
    NULL AS DMG_FLAG,
    NULL AS CREDIT_CARD_NO,
    NULL AS HDFC_LG_CODE,
    NULL AS IS_REQ97,
    a.data.RequestData.Purpose_Of_Insurance AS PUR_INS,
    a.data.RequestData.ClientInfo[1].PROP_MAIDEN_NAME AS OWNER_MAIDEN_NAME,
    a.data.RequestData.ClientInfo[1].PROP_MOTHER_NAME AS OWNER_MOTHER_NAME,
    NULL AS INS_MAIDEN_NAME,
    NULL AS INS_MOTHER_NAME,
    a.data.RequestData.AddressInfo[1].AddrTyp AS COMM_ADDR_TYPE,
    NULL AS PER_ADDR_TYPE,
    NULL AS DEFERMENT_PERIOD,
    NULL AS INCOME_BENEFIT_PERIOD,
    NULL AS INSTALMENTPREMIUM,
    NULL AS MODALBASICPREMIUM,
    NULL AS GST,
    NULL AS ANNUALPREM_WITHGST,
    NULL AS ANNUALPREM_WITHOUTGST,
    a.data.RequestData.PayInfo.ModalPremium AS MODAL_PREMIUM,
    NULL AS TRCP2_FLAG,
    NULL AS COMBO_ID,
    NULL AS COMBO_NAME,
    NULL AS COMBO_TYPE,
    NULL AS MULTI_RECEIPT_FLAG,
    'Y' AS IS_PRIMARY_APPLICATION,
    a.data.RequestData.ProductUIN AS PRODUCT_UIN,
    NULL AS FT_EXTRACT_STATUS,
    NULL AS FT_EXTRACTED_DATE,
    NULL AS UIN_LOGIN_DT,
    NULL AS WIN_BACK_OPTION,
    NULL  AS PIVC_ING_INSR_FLAG,
    NULL AS GRN_CHNL_FLG,
    NULL AS EAPP_ELD_FLG,
    a.data.RequestData.Priority_Name AS GRN_CHNL_DESC,
    NULL AS  PIVC_ING_INSR_TIMESTAMP,
    NULL AS REV_TPDAGENT_CODE,
    NULL AS IS_INTERNAL_FT,
    NULL AS SP_MOB_NO,
    NULL AS SP_EMAIL_ID,
    NULL AS RO_MOB_NO,
    NULL AS RO_EMAIL_ID,
    NULL AS FORM_FULFILMENT_LINK,
    a.data.RequestData.PIVC_ELIGIBLITY AS PIVC_ELLIGIBILITY,
    NULL AS FT_FLAG,
    NULL AS RO_NAME,
    NULL AS INSURED_EMAIL_ID,
    a.data.RequestData.AddressInfo[1].ContactNo AS PROP_MOB_NO,
    a.data.RequestData.Senior_Citizen_Flag AS SR_CITIZEN_FLAG,
    a.data.RequestData.Marginal_Income_Case AS MARGINAL_INCOME_CASE,
    a.data.RequestData.EMI_Flag AS EMI,
    NULL AS ANNUAL_INCOME,
    a.data.RequestData.PayInfo.AnnualPremium AS ANNUAL_PREMIUM,
    NULL AS INSTA_STATUS,
    NULL AS MASTER_POLICY_NO,
    NULL AS MASTER_POLICYHOLDER_NAME,
    NULL AS PAYMENT_RECEIVED_DATE,
    --NULL AS INSURED_MOBILE_NO,
    NULL AS LEAP_HEADER_ENTRY


FROM     T_JSON_OFFLINE_PAY a
where APP_NO = IN_APP_NO  and REQUEST_ID= IN_RequestID ;
--AND DT_CREATE='2022-02-07';
dbms_output.put_line( 'Insert into App_Details successfully' );
dbms_output.put_line ('SUCCESS');

SELECT TO_CHAR(APPL_RCV_DT,'YYYY-MM-DD HH24:MI:SS')
  INTO v_APPL_RCV_DT
  FROM POLICY
  where POLICY_NUMBER = IN_APP_NO;
/*
FOR rec IN
  (SELECT v_reqId AS v_reqId ,v_OR_NUM AS v_OR_NUM, v_AppNum AS v_AppNum FROM dual )
  LOOP*/
   OP_RESPONSE_JSON := '{
"RequestId":"'||v_reqId||'",
"ORNumber":"'||v_OR_NUM||'",
"ApplicationNo":"'||v_AppNum||'",
"PaymentAckDate":"'||v_APPL_RCV_DT||'"
}';
    dbms_output.put_line ('RESPONSE_JSON---->'||OP_RESPONSE_JSON);
 -- END LOOP;
EXCEPTION

WHEN OTHERS THEN
  strErr          := SQLERRM;
  p_RESPONSE_FLAG := strErr;
  OP_RESPONSE_JSON   := '{
"p_RESPONSE_FLAG":"'||p_RESPONSE_FLAG||'",
"RequestId":"'||v_reqId||'"

}';
  dbms_output.put_line ('RESPONSE_JSON---->'||OP_RESPONSE_JSON);


END;
