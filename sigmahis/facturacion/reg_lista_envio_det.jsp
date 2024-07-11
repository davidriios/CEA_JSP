<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.Lista"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="LE" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="FacMgr" scope="page" class="issi.facturacion.FacturaMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htFac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFac" scope="session" class="java.util.Vector" />
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
FacMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String aseguradora = request.getParameter("aseguradora");
String enviado = request.getParameter("enviado");
String aseg_is_axa = "N";
if(enviado==null) enviado = "N";
CommonDataObject cd = new CommonDataObject();
cd = SQLMgr.getData("select 'S' aseg_is_axa from dual where '"+aseguradora+"' in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual)) ");
if(cd!=null) aseg_is_axa=cd.getColValue("aseg_is_axa");
int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
int iconHeight = 20;
int iconWidth = 20;

ArrayList alRevCodeH = new ArrayList();
ArrayList alRevCodeA = new ArrayList();
ArrayList alRevCodeU = new ArrayList();
ArrayList alRevCodeE = new ArrayList();
alRevCodeH = sbb.getBeanList(ConMgr.getConnection(),"select rev_code as optValueColumn, rev_code||' - '||descripcion as optLabelColumn, rev_code as optTitleColumn from tbl_map_cod_x_cat_adm where estado = 'A' and categoria = 1 order by 2",CommonDataObject.class);
alRevCodeA = sbb.getBeanList(ConMgr.getConnection(),"select rev_code as optValueColumn, rev_code||' - '||descripcion as optLabelColumn, rev_code as optTitleColumn from tbl_map_cod_x_cat_adm where estado = 'A' and categoria = 3 order by 2",CommonDataObject.class);
alRevCodeU = sbb.getBeanList(ConMgr.getConnection(),"select rev_code as optValueColumn, rev_code||' - '||descripcion as optLabelColumn, rev_code as optTitleColumn from tbl_map_cod_x_cat_adm where estado = 'A' and categoria = 2 order by 2",CommonDataObject.class);
alRevCodeE = sbb.getBeanList(ConMgr.getConnection(),"select rev_code as optValueColumn, rev_code||' - '||descripcion as optLabelColumn, rev_code as optTitleColumn from tbl_map_cod_x_cat_adm where estado = 'A' and categoria = 4 order by 2",CommonDataObject.class);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htFac.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	<%
	if(type!=null && type.equals("1")){
	%>
	var aseguradora = parent.document.lista_envio.aseguradora.value;
	var fact_corp = parent.document.lista_envio.fact_corp.value;
	abrir_ventana1('../common/check_facturas.jsp?fp=lista_envio&mode=<%=mode%>&cod_empresa='+aseguradora+'&fact_corp='+fact_corp);

	<%
	}
	%>
	calc();
	newHeight();
}

function calc(){
	var iCounter = 0;
	if (iCounter > 0) return true;
	else return false;
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit(valor)) doSubmit();
}

function doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	document.form1.id.value = parent.document.lista_envio.id.value;
	document.form1.aseguradora.value = parent.document.lista_envio.aseguradora.value;
	document.form1.lista.value = parent.document.lista_envio.lista.value;
	document.form1.comentario.value = parent.document.lista_envio.comentario.value;
	if (eval('parent.document.lista_envio.enviado')) document.form1.enviado.value = parent.document.lista_envio.enviado.value;
	document.form1.fecha_envio.value = parent.document.lista_envio.fecha_envio.value;
	document.form1.estado.value = parent.document.lista_envio.estado.value;
	document.form1.mode.value = parent.document.lista_envio.mode.value;
	document.form1.fact_corp.value = parent.document.lista_envio.fact_corp.value;

	if (!parent.lista_envioValidation()){
		 parent.lista_envioBlockButtons(false);
		 //return false;
	} else if (document.form1.action.value == 'Guardar'){
		if (!form1Validation()){
			form1BlockButtons(false);
			//return false;
		} else document.form1.submit();
	} else{
		if(document.form1.action.value != 'Guardar'){parent.lista_envioBlockButtons(false); form1BlockButtons(false);}
		document.form1.submit();
	}

}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	if(size>0) return true;
	else{
		if(document.form1.action.value!='Guardar') return true;
		else {
			alert('Seleccione al menos una Factura!');
			document.form1.action.value = '';
			return false;
		}
	}
}

function borrar(i){
	var id = parent.document.lista_envio.id.value;
	var factura = eval('document.form1.factura'+i).value;
	parent.showPopWin('../common/run_process.jsp?fp=LISTA_ENVIO&actType=2&docType=LISTA_ENVIO&compania=<%=(String) session.getAttribute("_companyId")%>&docId='+id+'&docNo='+id+'&codigo='+factura,winWidth*.75,winHeight*.65,null,null,'');
}
function clearDetail(){
	document.form1.action.value = 'DEL';
	document.form1.clearHT.value = 'S';
	document.form1.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>

<%=fb.hidden("id",id)%>
<%=fb.hidden("aseguradora","")%>
<%=fb.hidden("lista","")%>
<%=fb.hidden("comentario","")%>
<%=fb.hidden("enviado_por","")%>
<%=fb.hidden("enviado","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("fecha_envio","")%>
<%=fb.hidden("fact_corp","")%>

<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <%
				int colspan = 8;
				%>
        <tr class="TextPanel">
          <td colspan="<%=colspan-2%>"><cellbytelabel>Detalle</cellbytelabel></td>
          <td colspan="2" align="right"><%=fb.button("addCuentas","Agregar Facturas",false,viewMode, "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader">
          <td width="8%" align="center"><cellbytelabel>Factura</cellbytelabel></td>
          <td width="20%" align="center"><cellbytelabel>Paciente</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
          <td width="23%" align="center"><cellbytelabel>Categor&iacute;a Admisi&oacute;n</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Cod. DGI</cellbytelabel></td>
          <td width="8%" align="center"><cellbytelabel><%if(aseg_is_axa.equals("S")){%>Rev. Code<%}%></cellbytelabel></td>
          <td width="3%" align="center">&nbsp;</td>
        </tr>
        <%
				key = "";
				if (htFac.size() != 0) al = CmnMgr.reverseRecords(htFac);
				for (int i=0; i<htFac.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htFac.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("lista_old"+i,cdo.getColValue("lista_old"))%>
        <%=fb.hidden("factura"+i,cdo.getColValue("factura"))%>
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
        <%=fb.hidden("facturar_a"+i,cdo.getColValue("facturar_a"))%>
        <%=fb.hidden("aseguradora"+i,cdo.getColValue("aseguradora"))%>
        <%=fb.hidden("aseguradora_nombre"+i,cdo.getColValue("aseguradora_nombre"))%>
        <%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
        <%=fb.hidden("categoria_nombre"+i,cdo.getColValue("categoria_nombre"))%>
        <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
        <%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
        <%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
        <%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
        <%=fb.hidden("nombre_paciente"+i,cdo.getColValue("nombre_paciente"))%>
        <%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
        <tr class="<%=color%>" >
          <td align="center"><%=cdo.getColValue("factura")%></td>
          <td align="center"><%=cdo.getColValue("nombre_paciente")%></td>
          <td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
					<td align="center"><%=cdo.getColValue("categoria_nombre")%></td>
					<td align="center"><%=cdo.getColValue("codigo_dgi")%></td>
					<td align="center">
					<%if(aseg_is_axa.equals("S")){%>
					<%if(cdo.getColValue("categoria").equals("1")){%>
					<%=fb.select("rev_code"+i,alRevCodeH,cdo.getColValue("rev_code"),false,false,0,"Text10",null,"",null,"S")%>
					<%} else if(cdo.getColValue("categoria").equals("2")){%>
					<%=fb.select("rev_code"+i,alRevCodeU,cdo.getColValue("rev_code"),false,false,0,"Text10",null,"",null,"S")%>
					<%} else if(cdo.getColValue("categoria").equals("3")){%>
					<%=fb.select("rev_code"+i,alRevCodeA,cdo.getColValue("rev_code"),false,false,0,"Text10",null,"",null,"S")%>
					<%} else if(cdo.getColValue("categoria").equals("4")){%>
					<%=fb.select("rev_code"+i,alRevCodeE,cdo.getColValue("rev_code"),false,false,0,"Text10",null,"",null,"S")%>
					<%}}%>
					</td>
          <td align="center" width="3%"><%if(enviado.equals("S") && cdo.getColValue("estado").equals("A")){%><authtype type='50'><a href="javascript:borrar(<%=i%>)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/error.png"></a></authtype><%} else {%><%=fb.submit("del"+i,"X",false,viewMode, "text10", "", "onClick=\"javascript: _doSubmit(this.value);\"")%><%}%></td>
        </tr>
        <%
				}
				%>
        <%=fb.hidden("keySize",""+htFac.size())%>
      </table></td>
  </tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{

	String companyId = (String) session.getAttribute("_companyId");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	if(request.getParameter("aseguradora")!=null) LE.addColValue("aseguradora", request.getParameter("aseguradora"));
	LE.addColValue("compania", (String) session.getAttribute("_companyId"));
	if(request.getParameter("id")!=null) LE.addColValue("id", request.getParameter("id"));
	if(request.getParameter("lista")!=null) LE.addColValue("lista", request.getParameter("lista"));
	if(request.getParameter("fecha_recibido")!=null) LE.addColValue("fecha_recibido", request.getParameter("fecha_recibido"));
	if(request.getParameter("comentario")!=null) LE.addColValue("comentario", request.getParameter("comentario"));
	if(request.getParameter("estado")!=null) LE.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("fact_corp")!=null) LE.addColValue("fact_corp", request.getParameter("fact_corp"));

	if(request.getParameter("enviado")!=null){
		LE.addColValue("enviado", request.getParameter("enviado"));
		if(request.getParameter("enviado").equals("S")){
			if(request.getParameter("fecha_envio")!=null) LE.addColValue("fecha_envio", request.getParameter("fecha_envio"));
			LE.addColValue("enviado_por", (String) session.getAttribute("_userName"));
		}
	}
	htFac.clear();
    vFac.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("aseguradora"+i)!=null) cdo.addColValue("aseguradora", request.getParameter("aseguradora"));
		if(request.getParameter("categoria"+i)!=null) cdo.addColValue("categoria", request.getParameter("categoria"+i));
		if(request.getParameter("categoria_nombre"+i)!=null) cdo.addColValue("categoria_nombre", request.getParameter("categoria_nombre"+i));
		cdo.addColValue("compania", LE.getColValue("compania"));
		if(request.getParameter("id"+i)!=null) cdo.addColValue("id", request.getParameter("id"+i));
		if(request.getParameter("lista"+i)!=null) cdo.addColValue("lista", request.getParameter("lista"+i));
		if(request.getParameter("lista_old"+i)!=null) cdo.addColValue("lista_old", request.getParameter("lista_old"+i));
		if(request.getParameter("secuencia"+i)!=null) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
		if(request.getParameter("factura"+i)!=null) cdo.addColValue("factura", request.getParameter("factura"+i));
		if(request.getParameter("facturar_a"+i)!=null) cdo.addColValue("facturar_a", request.getParameter("facturar_a"+i));
		if(request.getParameter("usuario_creacion"+i)!=null) cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
		if(request.getParameter("fecha_creacion"+i)!=null) cdo.addColValue("fecha_creacion", request.getParameter("fecha_creacion"+i));
		if(request.getParameter("estado"+i)!=null) cdo.addColValue("estado", request.getParameter("estado"+i));
		if(request.getParameter("pac_id"+i)!=null) cdo.addColValue("pac_id", request.getParameter("pac_id"+i));
		if(request.getParameter("admision"+i)!=null) cdo.addColValue("admision", request.getParameter("admision"+i));
		if(request.getParameter("nombre_paciente"+i)!=null) cdo.addColValue("nombre_paciente", request.getParameter("nombre_paciente"+i));
		if(request.getParameter("monto"+i)!=null) cdo.addColValue("monto", request.getParameter("monto"+i));
		if(request.getParameter("rev_code"+i)!=null) cdo.addColValue("rev_code", request.getParameter("rev_code"+i));

		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("del"+i)==null){
			try {
				if (!vFac.contains(cdo.getColValue("factura"))) {
					htFac.put(key, cdo);
					vFac.add(cdo.getColValue("factura"));
					al.add(cdo);
				}
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
			vFac.remove(cdo.getColValue("factura"));
		}
	}

	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../facturacion/reg_lista_envio_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2&fg="+fg+"&fp="+fp+"&aseguradora="+aseguradora);
		return;
	}


	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar Facturas")){
		response.sendRedirect("../facturacion/reg_lista_envio_det.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&aseguradora="+aseguradora);
		return;
	}

	Lista ls = new Lista();
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&id="+id+"&fg="+fg+"&aseguradora="+aseguradora);
	if (request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		if (mode.equalsIgnoreCase("add")){
			LE.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			LE.addColValue("fecha_creacion", CmnMgr.getCurrentDate("dd/mm/yyyy"));
			ls.setCdo(LE);
			ls.setAlDet(al);
			FacMgr.addListaEnvio(ls);
			id = FacMgr.getPkColValue("id");
		} else {
			LE.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			LE.addColValue("fecha_modificacion", CmnMgr.getCurrentDate("dd/mm/yyyy"));
			ls.setCdo(LE);
			ls.setAlDet(al);
			FacMgr.updateListaEnvio(ls);
			id=request.getParameter("id");
		}
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	parent.document.lista_envio.errCode.value = <%=FacMgr.getErrCode()%>;
	parent.document.lista_envio.errMsg.value = '<%=FacMgr.getErrMsg()%>';
	parent.document.lista_envio.id.value = '<%=id%>';
	parent.document.lista_envio.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
