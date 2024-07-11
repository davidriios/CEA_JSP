<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
int iconHeight = 48;
int iconWidth = 48;

if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
	}
	String msgRef = request.getParameter("msgRef");
	String msgType = request.getParameter("msgType");
	String msgSent = request.getParameter("msgSent");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	String msgSubject = request.getParameter("msgSubject");

	if (msgRef == null) msgRef = "";
	if (msgType == null) msgType = "EMAIL";
	if (msgSent == null) msgSent = "N";
	if (fDate == null) fDate = "";
	if (tDate == null) tDate = "";
	if (msgSubject == null) msgSubject = "";

	StringBuffer sbSql = new StringBuffer();

	sbSql.append("select t.msg_id, t.msg_type, t.msg_ref, t.msg_from, t.msg_to, t.msg_subject, t.msg_text, t.msg_status, t.notify_flag, t.notify_user, to_char(t.msg_date,'dd/mm/yyyy hh12:mi:ss am') as msg_date, nvl(t.msg_sent_flag,'N') as msg_sent_flag, to_char(t.msg_sent_date,'dd/mm/yyyy hh12:mi:ss am') as msg_sent_date, t.msg_sent_retry, t.msg_sent_error, t.msg_email, t.msg_attach_flag, t.msg_attach_file_path, t.msg_email_type, t.other4 from tbl_sec_mail_q t where 1=1 ");
	if(!msgRef.equalsIgnoreCase("")){
			sbSql.append(" and t.msg_ref='"+msgRef+"'");
			sbSql.append(" ");
	}
	if(!msgType.equalsIgnoreCase("")){
		sbSql.append(" and upper(t.msg_Type) = '");
		sbSql.append(msgType);
		sbSql.append("'");
	}
	if(!msgSubject.equalsIgnoreCase("")){
		sbSql.append(" and upper(t.msg_subject) like '%");
		sbSql.append(msgSubject);
		sbSql.append("%'");
	}
	if(!fDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(t.msg_date) >= to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!tDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(t.msg_date) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}

	if (!msgSent.trim().equals("")) sbSql.append(" and upper(nvl(t.msg_sent_flag,'N'))='"+msgSent+"'");
		sbSql.append(" order by t.msg_subject");
		StringBuffer sbSqlT = new StringBuffer();
		sbSqlT.append("select * from (select rownum as rn, z.* from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(") z) where rn between ");
		sbSqlT.append(previousVal);
		sbSqlT.append(" and ");
		sbSqlT.append(nextVal);
		al = SQLMgr.getDataList(sbSqlT.toString());
		sbSqlT = new StringBuffer();
		sbSqlT.append("select count(*) as count from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(")");
		rowCount = CmnMgr.getCount(sbSqlT.toString());




	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Email Sender Message List - '+document.title;
function doAction(){}
function goOption(option){
	switch(option){
		case 1:showPopWin('../process/gen_mail.jsp?actType=50',winWidth*.75,winHeight*.65,null,null,'');break;
		case 2:showPopWin('../process/gen_mail.jsp?actType=51',winWidth*.75,winHeight*.65,null,null,'');;break;
		case 3:showPopWin('../process/gen_mail.jsp?actType=53',winWidth*.75,winHeight*.65,null,null,'');;break;
	}
}
function mouseOver(obj,option){
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option){
		case 1:msg='Generar Correo de Morosos';break;
		case 2:msg='Generar Correo de Recordatorio';break;
		case 3:msg='Generar Correo de Vacunacion 3er Edad';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">
			<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
			<authtype type='50'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/time-money.jpg"></a></authtype>
			<authtype type='51'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/scheduled-tasks.jpg"></a></authtype>
			<a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/vacuna.png"></a>
		</td>
	</tr>
	<tr>
		<td>
		<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<%
					fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td>
					Reference:
					<%=fb.select("msgRef","PMMOROSOS=Plan Médico - Morosos,RECORDIS=Plan Médico - Recordatorio,VACUN3EDAD=Plan Médico - VACUNA 3ER EDAD,PLA_EMPL_COMPROB=Planilla - Comprobante Pago Empleado,INV_LOTE_FECHA_VENCE=Inventario - Lote/Fecha Vencimiento,CXP_CHK_COMPROB=CXP Comprobante Pago",msgRef,false,false,0,"T")%>
					Asunto:
					<%=fb.textBox("msgSubject",msgSubject, false, false, false, 20, 40, "text12", "", "", "", false, "", "")%>
					Email Enviado:
					<%=fb.select("msgSent","Y=Si,N=No",msgSent,false,false,0,"T")%>
					Enviado
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fDate"/>
					<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
					<jsp:param name="nameOfTBox2" value="tDate"/>
					<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
					</jsp:include>
					<%=fb.submit("go","Ir")%>
					<!--<input type="checkbox" id="pCtrlHeader" name="pCtrlHeader">
					<label for="pCtrlHeader">Esconder cabecera (Excel)</label>-->
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;<!--<authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype>--></td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("msgRef", msgRef)%>
					<%=fb.hidden("msgSent", msgSent)%>
					<%=fb.hidden("msgSubject", msgSubject)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("msgType",""+msgType)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("msgRef", msgRef)%>
					<%=fb.hidden("msgSent", msgSent)%>
					<%=fb.hidden("msgSubject", msgSubject)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("msgType",""+msgType)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="8%">Msg ID</td>
					<td width="6%">Msg Ref</td>
					<td width="10%">Email To</td>
					<td width="6%">Msg date</td>
					<td width="14%">Subject</td>
					<td width="35%">Body</td>
					<td width="3%">Status</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";

				 %>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("msg_id")%></td>
					<td><%=cdo.getColValue("msg_ref")%></td>
					<td><%=cdo.getColValue("msg_to")%></td>
					<td align="center"><%=cdo.getColValue("msg_date")%></td>
					<td><%=cdo.getColValue("msg_subject")%></td>
					<td><%=cdo.getColValue("msg_text")%></td>
					<td align="center"><%=cdo.getColValue("msg_sent_flag")%></td>
					<%
					if(cdo.getColValue("msg_sent_flag").equals("N")){
					%>
					<td align="center">&nbsp;<!--<authtype type='4'><a href="#" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Enviar Correo</a></authtype>--></td>
					<%
					}else{
					%>
					<td align="center">&nbsp;</td>
					<%
					}
					%>
				</tr>
				<%
				 }
				 %>
			</table>
			<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("msgRef", msgRef)%>
					<%=fb.hidden("msgSent", msgSent)%>
					<%=fb.hidden("msgSubject", msgSubject)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("msgType",""+msgType)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("msgRef", msgRef)%>
					<%=fb.hidden("msgSent", msgSent)%>
					<%=fb.hidden("msgSubject", msgSubject)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("msgType",""+msgType)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
