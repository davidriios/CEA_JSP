<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cop" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								
INF800982						CLASIFICACION DE ORDENES DE PAGO
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");

boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="orden_pago";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		sql = "select codigo, descripcion, estado, nivel_aprobar, nivel_vobo, nivel_autorizar, usuario_creacion, usuario_modificacion from tbl_cxp_orden_clasificacion order by codigo";
			alTPR = SQLMgr.getDataList(sql);
			cop.clear();
			for(int i=0;i<alTPR.size();i++){
				CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					cop.put(key, cdo);
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			}
		}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function chkNumEmpleado(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true && eval('document.form.num_empleado'+i).value==''){
			alert('Esta acción de ingreso no le ha registrado el número de empleado, esta es una información de vital importancia por lo que no podrá actualizar la acción!!!');
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}


function doSubmit(action){
	document.form.baction.value 			= action;
	if(!formValidation()){
		formBlockButtons(fasle);
		return false
	} else {
		document.form.submit();
	}
}

function chkSelected(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" colspan="2" width="70%"><cellbytelabel>Clasificaciones</cellbytelabel></td>
          <td align="center" colspan="3" width="21%"><cellbytelabel>Aprobaciones Necesarias</cellbytelabel></td>
          <td align="center" width="9%"><%=fb.button("addClasic","Agregar",false,viewMode, "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="center" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
          <td align="center" width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="7%"><cellbytelabel>Aprobar</cellbytelabel><br><cellbytelabel>1 (Depto)</cellbytelabel></td>
          <td align="center" width="7%"><cellbytelabel>Aprobar</cellbytelabel><br><cellbytelabel>2 (Vobo)</cellbytelabel></td>
          <td align="center" width="7%"><cellbytelabel>Aprobar</cellbytelabel><br><cellbytelabel>3 (Pago)</cellbytelabel></td>
          <td align="center" width="9%"><cellbytelabel>Estado</cellbytelabel></td>
        </tr>
        <%
				if (cop.size() > 0) alTPR = CmnMgr.reverseRecords(cop);
				for (int i=0; i<cop.size(); i++){
					key = alTPR.get(i).toString();
          CommonDataObject cdo = (CommonDataObject) cop.get(key);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
        <tr class="<%=color%>" align="center">
          <td align="left"><%=fb.intBox("codigo"+i,cdo.getColValue("codigo"),true,false,true,5,"text10",null,"")%></td>
          <td align="left"><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,false,80,"text10",null,"")%></td>
          <td align="center"><%=fb.checkbox("nivel_aprobar"+i,""+i, (cdo.getColValue("nivel_aprobar").equals("S")?true:false), false, "text10", "", "")%></td>
          <td align="center"><%=fb.checkbox("nivel_vobo"+i,""+i, (cdo.getColValue("nivel_vobo").equals("S")?true:false), false, "text10", "", "")%></td>
          <td align="center"><%=fb.checkbox("nivel_autorizar"+i,""+i, (cdo.getColValue("nivel_autorizar").equals("S")?true:false), false, "text10", "", "")%></td>
          <td align="center"><%=fb.select("estado"+i,"A=Activa,I=Inactiva", cdo.getColValue("estado"), false, false, 0, "text10", "", "")%></td>
        </tr>
        <%}%>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	cop.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("codigo", request.getParameter("codigo"+i));
			cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("estado", request.getParameter("estado"+i));
			if(request.getParameter("nivel_aprobar"+i)!= null) cdo.addColValue("nivel_aprobar", "S");
			else cdo.addColValue("nivel_aprobar", "N");
			if(request.getParameter("nivel_vobo"+i)!= null) cdo.addColValue("nivel_vobo", "S");
			else cdo.addColValue("nivel_vobo", "N");
			if(request.getParameter("nivel_autorizar"+i)!= null) cdo.addColValue("nivel_autorizar", "S");
			else cdo.addColValue("nivel_autorizar", "N");
			cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				cop.put(key, cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			alTPR.add(cdo);
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Agregar")){
		CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("codigo", "0");
			cdo.addColValue("descripcion", "");
			cdo.addColValue("estado", "A");
			cdo.addColValue("nivel_aprobar", "N");
			cdo.addColValue("nivel_vobo", "N");
			cdo.addColValue("nivel_autorizar", "N");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				cop.put(key, cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			alTPR.add(cdo);
		response.sendRedirect("../cxp/clasificacion_orden_pago_det.jsp?mode="+mode+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}
	

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		OrdPagoMgr.addClasificacionOrdenPago(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
parent.document.form1.errCode.value='<%=OrdPagoMgr.getErrCode()%>';
parent.document.form1.errMsg.value='<%=OrdPagoMgr.getErrMsg()%>';
parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>