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
<jsp:useBean id="copUser" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="copUserKey" scope="session" class="java.util.Hashtable" />

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
String usuario = request.getParameter("usuario");

boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="orden_pago";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		sql = "select a.compania, a.unidad_adm, a.usuario, a.clasificacion, b.descripcion, a.nivel_aprobar, a.nivel_vobo, a.nivel_autorizar, a.usuario_creacion, a.usuario_modificacion from tbl_cxp_usuario_x_unidad_clasi a, tbl_cxp_orden_clasificacion b where a.compania = "+compania+" and a.unidad_adm = "+unidad_ejec+" and a.usuario = '"+usuario+"' and a.clasificacion = b.codigo order by codigo";
			alTPR = SQLMgr.getDataList(sql);
			copUser.clear();
			copUserKey.clear();
			for(int i=0;i<alTPR.size();i++){
				CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					copUser.put(key, cdo);
					copUserKey.put(cdo.getColValue("clasificacion"), key);
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
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/check_user_clasificacion.jsp?fp=user_orden_pago&mode=<%=mode%>&compania=<%=compania%>&unidad_ejec=<%=unidad_ejec%>&usuario=<%=usuario%>');

	<%
	}
	%>
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
<%=fb.hidden("compania",""+compania)%>
<%=fb.hidden("unidad_ejec",""+unidad_ejec)%>
<%=fb.hidden("usuario",""+usuario)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" colspan="2" width="70%"><cellbytelabel>Clase de Ordenes a las que tiene acceso</cellbytelabel></td>
          <td align="center" colspan="3" width="21%"><cellbytelabel>Aprobaciones que puede realizar</cellbytelabel></td>
          <td align="center" width="9%"><%=fb.button("addClasic","Agregar",false,viewMode, "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="center" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
          <td align="center" width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="7%"><cellbytelabel>Aprobar</cellbytelabel><br><cellbytelabel>1 (Depto)</cellbytelabel></td>
          <td align="center" width="7%"><cellbytelabel>Aprobar</cellbytelabel><br><cellbytelabel>2 (Vobo)</cellbytelabel></td>
          <td align="center" width="7%"><cellbytelabel>Aprobar</cellbytelabel><br><cellbytelabel>3 (Pago)</cellbytelabel></td>
          <td align="center" width="9%">&nbsp;</td>
        </tr>
        <%
				if (copUser.size() > 0) alTPR = CmnMgr.reverseRecords(copUser);
				for (int i=0; i<copUser.size(); i++){
					key = alTPR.get(i).toString();
          CommonDataObject cdo = (CommonDataObject) copUser.get(key);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
        <tr class="<%=color%>" align="center">
          <td align="left"><%=fb.intBox("clasificacion"+i,cdo.getColValue("clasificacion"),true,false,true,5,"text10",null,"")%></td>
          <td align="left"><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,false,80,"text10",null,"")%></td>
          <td align="center"><%=fb.checkbox("nivel_aprobar"+i,""+i, (cdo.getColValue("nivel_aprobar").equals("S")?true:false), false, "text10", "", "")%></td>
          <td align="center"><%=fb.checkbox("nivel_vobo"+i,""+i, (cdo.getColValue("nivel_vobo").equals("S")?true:false), false, "text10", "", "")%></td>
          <td align="center"><%=fb.checkbox("nivel_autorizar"+i,""+i, (cdo.getColValue("nivel_autorizar").equals("S")?true:false), false, "text10", "", "")%></td>
          <td align="center"><%=fb.submit("del"+i,"X",false,false, "text10", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
        </tr>
        <%}%>
        <tr class="TextRow02">
          <td align="right" colspan="6"> 
          <%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%> 
          </td>
        </tr>
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
	String dl = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	copUser.clear();
	copUserKey.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("del"+i)==null){
			cdo.addColValue("clasificacion", request.getParameter("clasificacion"+i));
			cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("usuario", request.getParameter("usuario"));
			cdo.addColValue("unidad_adm", request.getParameter("unidad_ejec"));

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
				copUser.put(key, cdo);
				copUserKey.put(cdo.getColValue("clasificacion"), key);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			alTPR.add(cdo);
		} else dl = "1";			
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Agregar")){
		response.sendRedirect("../cxp/usuario_x_clasificacion_op.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&compania="+compania+"&unidad_ejec="+unidad_ejec+"&usuario="+usuario);
		return;
	}

	if (!dl.equals("")){
		response.sendRedirect("../cxp/usuario_x_clasificacion_op.jsp?mode="+mode+"&change=1&type=0&fg="+fg+"&fp="+fp+"&compania="+compania+"&unidad_ejec="+unidad_ejec+"&usuario="+usuario);
		return;
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		OrdPagoMgr.addClasificacionUsuario(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%if(OrdPagoMgr.getErrCode().equals("1")){%>
alert('<%=OrdPagoMgr.getErrMsg()%>');
window.close();
<%
} else throw new Exception(OrdPagoMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>