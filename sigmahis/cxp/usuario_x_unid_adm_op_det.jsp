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
<jsp:useBean id="copKey" scope="session" class="java.util.Hashtable" />

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
String compania = request.getParameter("compania");
String unidad_ejec = request.getParameter("unidad_ejec");
boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="orden_pago";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		sql = "select usuario, nombre, observacion, orden_pago, usuario_creacion, usuario_modificacion from tbl_CXP_USUARIO_X_UNIDAD where compania = "+compania+" and unidad_adm = "+unidad_ejec+" order by usuario";
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
					copKey.put(cdo.getColValue("usuario"), key);
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
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/check_user.jsp?fp=user_orden_pago&mode=<%=mode%>&compania=<%=compania%>&unidad_ejec=<%=unidad_ejec%>');

	<%
	}
	%>
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

function addClasificacion(user){
	var x = getDBData('<%=request.getContextPath()%>', '1', 'tbl_cxp_usuario_x_unidad', 'compania = <%=compania%> and unidad_adm = <%=unidad_ejec%> and usuario = \''+user+'\'','');
	if(x==1)
		abrir_ventana1('../cxp/usuario_x_clasificacion_op.jsp?fp=user_orden_pago&mode=<%=mode%>&compania=<%=compania%>&unidad_ejec=<%=unidad_ejec%>&usuario='+user);
	else alert('Debe Guardar al usuario antes de asignarle las clases de acceso!');
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
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("unidad_ejec",unidad_ejec)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="15%"><cellbytelabel>Usuario</cellbytelabel></td>
          <td align="center" width="35%"><cellbytelabel>Nombre del Usuario</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Orden Pago</cellbytelabel></td>
          <td align="center" width="33%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
          <td align="center" width="7%"><%=fb.button("addClasic","Agregar",false,viewMode, "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
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
          <td align="left"><%=fb.textBox("usuario"+i,cdo.getColValue("usuario"),true,false,true,20,"text10",null,"")%></td>
          <td align="left"><%=fb.textBox("nombre"+i,cdo.getColValue("nombre"),false,false,true,50,"text10",null,"")%></td>
          <td align="center"><%=fb.select("orden_pago"+i,"1=Confeccion,2=Aprobacion,3=Conf./Aprob.", cdo.getColValue("orden_pago"), false, false, 0, "text10", "", "", "", "S")%></td>
          <td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,50,2,"text10",null,"")%> </td>
          <td align="center"><a href="javascript:addClasificacion('<%=cdo.getColValue("usuario")%>')"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Acceso por Clasificacion"></a></td>
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
	copKey.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("usuario", request.getParameter("usuario"+i));
			cdo.addColValue("nombre", request.getParameter("nombre"+i));
			cdo.addColValue("orden_pago", request.getParameter("orden_pago"+i));
			if(request.getParameter("observacion"+i)!= null && !request.getParameter("observacion"+i).equals("")) cdo.addColValue("observacion", request.getParameter("observacion"+i));
			cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", request.getParameter("compania"));
			cdo.addColValue("unidad_adm", request.getParameter("unidad_ejec"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				cop.put(key, cdo);
				copKey.put(cdo.getColValue("usuario"), key);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			alTPR.add(cdo);
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Agregar")){
		response.sendRedirect("../cxp/usuario_x_unid_adm_op_det.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&compania="+compania+"&unidad_ejec="+unidad_ejec);
		return;
	}
	

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		OrdPagoMgr.addUsuario(alTPR);
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
parent.document.form1.baction.value='<%=request.getParameter("baction")%>';
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