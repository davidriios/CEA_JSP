<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
String lista = request.getParameter("lista");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String aseguradora = request.getParameter("aseguradora");
String aseguradoraDesc = request.getParameter("aseguradoraDesc");
String categoria = request.getParameter("categoria");

boolean viewMode = false;
int iconSize = 18;

if(fg==null) fg = "";
if(fp==null) fp = "";
if(lista==null) lista = "";
if(tDate==null) tDate = "";
if(fDate==null) fDate = "";
if(aseguradora==null) aseguradora = "";
if(aseguradoraDesc==null) aseguradoraDesc = "";
if(categoria==null) categoria = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){

	if(!lista.equals("")) appendFilter = " and a.numero_lista = "+lista;
	if(!tDate.equals("")) appendFilter += " and trunc(a.fecha) >= to_date('"+fDate+"', 'dd/mm/yyyy')";
	if(!fDate.equals("")) appendFilter += " and trunc(a.fecha) <= to_date('"+tDate+"', 'dd/mm/yyyy')";
	if(!aseguradora.equals("")) appendFilter += " and a.aseguradora = "+aseguradora;
	if(!categoria.equals("")) appendFilter += " and a.categoria = "+categoria;

	sql = "select anio, categoria, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) categoria_desc, aseguradora, (select nombre from tbl_adm_empresa where codigo = a.aseguradora) aseguradora_desc, usuario, numero_lista, to_char(fecha,'dd/mm/yyyy') fecha, a.estado from tbl_fac_lista_envio_parametros a where estado in ('A','E') and usuario = '"+(String) session.getAttribute("_userName")+"' "+appendFilter+" order by anio, aseguradora, categoria, numero_lista";
al = SQLMgr.getDataList(sql);
	sql = "select anio, categoria, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) categoria_desc, aseguradora, (select nombre from tbl_adm_empresa where codigo = a.aseguradora) aseguradora_desc, usuario, numero_lista, to_char(fecha,'dd/mm/yyyy') fecha from tbl_fac_lista_envio_parametros a where estado = 'I' and usuario = '"+(String) session.getAttribute("_userName")+"' "+appendFilter+" order by anio, aseguradora, categoria, numero_lista";
al2 = SQLMgr.getDataList(sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturación- '+document.title;

function doAction(){
}

function doSubmit(value){
document.orden_pago.action.value = value;
}

function reloadPage(){
	var categoria = document.search00.categoria.value;
	var aseguradora = document.search00.aseguradora.value;
	var aseguradoraDesc = document.search00.aseguradoraDesc.value;
	var fDate = document.search00.fDate.value;
	var tDate = document.search00.tDate.value;
	var lista = document.search00.lista.value;
window.location = '../facturacion/inactiva_lista_envio.jsp?categoria='+categoria+'&aseguradora='+aseguradora+'&aseguradoraDesc='+aseguradoraDesc+'&fDate='+fDate+'&tDate='+tDate+'&lista='+lista;
}
function showEmpresaList()
{
	abrir_ventana1('../common/search_empresa.jsp?fp=edit_list_aseg');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
    	<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
               <tr class="TextFilter">
          <%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
          <%=fb.formStart()%>
          <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
          <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
                <td colspan="6">
                  <cellbytelabel>Categor&iacute;a</cellbytelabel>
                  <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_adm_categoria_admision order by codigo","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
                  <cellbytelabel>Fecha Lista</cellbytelabel>:
                  <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="2" />
                  <jsp:param name="nameOfTBox1" value="fDate" />
                  <jsp:param name="valueOfTBox1" value="<%=fDate%>" />
                  <jsp:param name="nameOfTBox2" value="tDate" />
                  <jsp:param name="valueOfTBox2" value="<%=tDate%>" />
                  <jsp:param name="fieldClass" value="Text10" />
                  <jsp:param name="buttonClass" value="Text10" />
                  </jsp:include>
									<cellbytelabel>Num. Lista</cellbytelabel>:
									<%=fb.textBox("lista",lista,false,false,false,5,"Text10",null,null)%>
                  <cellbytelabel>Aseguradora</cellbytelabel>:
									<%=fb.intBox("aseguradora",aseguradora,false,false,false,5,"Text10",null,"")%> 
                  <%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,false,30,"Text10",null,null)%> 
                  <%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%> 
									<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
                  <%=fb.formEnd()%>
                </td>
              </tr>
			  <tr>
          <td>
          	<table align="center" width="99%" cellpadding="0" cellspacing="1">
              <%
							fb = new FormBean("orden_pago","","post");
							%>
              <%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("errCode","")%> <%=fb.hidden("errMsg","")%> <%=fb.hidden("saveOption","")%> <%=fb.hidden("clearHT","")%> <%=fb.hidden("action","")%> <%=fb.hidden("fg",fg)%>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>LISTA DE ENVIO DE FACTURAS ACTIVAS</cellbytelabel></td>
              </tr>
              <tr class="">
              	<td colspan="6">
		<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:240">
		<div id="list_op" width="100%" style="overflow;position:absolute">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center"><cellbytelabel>Usuario</cellbytelabel></td>
                <td align="center"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
                <td align="center"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
                <td align="center"><cellbytelabel>Aseguradora</cellbytelabel></td>
                <td align="center"><cellbytelabel>No. Lista</cellbytelabel></td>
                <td align="center"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
                <td align="center"><cellbytelabel>Estado</cellbytelabel></td>
              </tr>
              <%
							for (int i=0; i<al.size(); i++){
								cdo = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
						%>
							<%=fb.hidden("usuario"+i,cdo.getColValue("usuario"))%>
							<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
							<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
							<%=fb.hidden("aseguradora"+i,cdo.getColValue("aseguradora"))%>
							<%=fb.hidden("numero_lista"+i,cdo.getColValue("numero_lista"))%>
							<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center"><%=cdo.getColValue("usuario")%> </td>
                <td align="center"><%=cdo.getColValue("anio")%> </td>
                <td><%=cdo.getColValue("categoria")%>-<%=cdo.getColValue("categoria_desc")%></td>
                <td><%=cdo.getColValue("aseguradora")%>-<%=cdo.getColValue("aseguradora_desc")%></td>
                <td align="center"><%=cdo.getColValue("numero_lista")%> </td>
                <td align="center"><%=cdo.getColValue("fecha")%></td>
                <td align="center"><%=fb.select("estado"+i,"A=Activa,I=Inactiva", cdo.getColValue("estado"), false, false,0,"text10",null,"")%> </td>
              </tr>
              <%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <tr>
                <td colspan="6">&nbsp;</td>
              </tr>
              <tr class="TextRow02">
                <td colspan="6" align="right">
                  <%=fb.submit("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%>
                </td>
              </tr>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>LISTA DE ENVIO DE FACTURAS INACTIVAS</cellbytelabel></td>
              </tr>
              <tr class="">
              	<td colspan="6">
		<div id="list_opMain2" width="100%" style="overflow:scroll;position:relative;height:240">
		<div id="list_op2" width="100%" style="overflow;position:absolute">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center"><cellbytelabel>Usuario</cellbytelabel></td>
                <td align="center"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
                <td align="center"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
                <td align="center"><cellbytelabel>Aseguradora</cellbytelabel></td>
                <td align="center"><cellbytelabel>No. Lista</cellbytelabel></td>
                <td align="center"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
                <td align="center"><cellbytelabel>Estado</cellbytelabel></td>
              </tr>
              <%
							for (int i=0; i<al2.size(); i++){
								cdo = (CommonDataObject) al2.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
						%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center"><%=cdo.getColValue("usuario")%> </td>
                <td align="center"><%=cdo.getColValue("anio")%> </td>
                <td><%=cdo.getColValue("categoria")%>-<%=cdo.getColValue("categoria_desc")%></td>
                <td><%=cdo.getColValue("aseguradora")%>-<%=cdo.getColValue("aseguradora_desc")%></td>
                <td align="center"><%=cdo.getColValue("numero_lista")%> </td>
                <td align="center"><%=cdo.getColValue("fecha")%></td>
                <td align="center">Inactiva</td>
              </tr>
              <%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <%=fb.formEnd(true)%>
              <!-- ================================   F O R M   E N D   H E R E   ================================ -->
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
int keySize = Integer.parseInt(request.getParameter("keySize"));

al = new ArrayList();
for(int i=0;i<keySize;i++){
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_fac_lista_envio_parametros");
	cdo.addColValue("anio", request.getParameter("anio"+i));
	cdo.addColValue("categoria", request.getParameter("categoria"+i));
	cdo.addColValue("aseguradora", request.getParameter("aseguradora"+i));
	cdo.addColValue("numero_lista", request.getParameter("numero_lista"+i));
	cdo.addColValue("estado", request.getParameter("estado"+i));
	cdo.setWhereClause("anio="+cdo.getColValue("anio")+" and categoria="+cdo.getColValue("categoria")+" and aseguradora="+cdo.getColValue("aseguradora")+" and numero_lista="+cdo.getColValue("numero_lista"));
	al.add(cdo);
}
System.out.println("action......="+request.getParameter("action"));
if (request.getParameter("action").equals("Guardar")){
	SQLMgr.updateList(al);
}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
alert('<%=SQLMgr.getErrMsg()%>');
window.location = '<%=request.getContextPath()%>/facturacion/inactiva_lista_envio.jsp';
<%
} else throw new Exception(SQLMgr.getErrMsg());
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
