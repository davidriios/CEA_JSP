
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="java.io.*"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String compania = (String) session.getAttribute("_companyId");	
String fg = request.getParameter("fg");
String almacen = request.getParameter("almacen");

String sql ="";
String classCode ="";
String familyCode ="";
String wh ="";
String popUp ="";
if(almacen == null ) almacen = "";

if(fg == null ) fg = "RA";
if(fg.trim().equals("CM"))popUp="abrir_ventana1";
else popUp="abrir_ventana";


sql = "select i.art_familia value_col, i.art_familia||' - '||a.nombre as label_col, i.art_familia as title_col, i.compania||'-'||i.codigo_almacen as key_col from (select distinct compania, art_familia, codigo_almacen from tbl_inv_inventario where compania="+(String) session.getAttribute("_companyId")+") i, tbl_inv_familia_articulo a where i.compania=a.compania(+) and i.art_familia=a.cod_flia(+) order by i.compania, i.codigo_almacen, a.nombre";
		XMLCreator xc = new XMLCreator(ConMgr);
		 xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"familyCode.xml",sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario - '+document.title;
function doAction()
{
}
function showReporte(fg, xtraOpt)
{
	var depto     = eval('document.form0.depto').value;
	var titulo     = eval('document.form0.titulo').value;
	var almacen     = eval('document.form0.wh').value;
	var familia     = eval('document.form0.familyCode').value;
	var clase       = eval('document.form0.classCode').value;
	var articulo     = eval('document.form0.codigo').value;
	
	var tipo     = eval('document.form0.tipo').value;
	var existencia       = eval('document.form0.existencia').value;
	var reporte     = eval('document.form0.reporte').value;
	var mes     = eval('document.form0.mes').value;
	var anio       = eval('document.form0.anio').value;
	var descripcion       = eval('document.form0.descripcion').value;
	var consignacion       = eval('document.form0.consignacion').value;
	var anaquel       = eval('document.form0.anaquel').value;
    var anaquelHasta  = eval('document.form0.anaquelHasta').value;
	if(fg=='RC')reporte='F';
	if(fg=='RH')reporte='C';
	if(fg == 'RH' && mes =='' && anio =='') alert('Debe escojer el Mes para Consultar las  Existencias');
	else {
      if (!xtraOpt) <%=popUp%>('../inventario/print_articulos_c_s_existencia.jsp?fg='+fg+'&almacen='+almacen+'&depto='+depto+'&titulo='+titulo+'&familia='+familia+'&clase='+clase+'&articulo='+articulo+'&tipo='+tipo+'&existencia='+existencia+'&reporte='+reporte+'&mes='+mes+'&anio='+anio+'&descripcion='+descripcion+'&consignacion='+consignacion+'&anaquel='+anaquel+'&anaquelHasta='+anaquelHasta);
      else <%=popUp%>('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_articulos_c_s_existencia.rptdesign&fg='+fg+'&almacen='+almacen+'&depto='+depto+'&titulo='+titulo+'&familia='+familia+'&clase='+clase+'&articulo='+articulo+'&tipo='+tipo+'&existencia='+existencia+'&reporte='+reporte+'&mes='+mes+'&anio='+anio+'&descripcion='+descripcion+'&consignacion='+consignacion+'&anaquel='+anaquel+'&anaquelHasta='+anaquelHasta+'&pCtrlHeader=true');
    }

}
function buscaPeriodo()
{
	var almacen     = eval('document.form0.wh').value;
	if(almacen ==' ')alert('DEBE ESCOJER EL ALMACEN PARA PODER CONSULTAR LOS MESES');
	else <%=popUp%>('../inventario/sel_periodo.jsp?fp=RA&almacen='+almacen);

}
function buscaArticulo()
{
	var msg ='';
	var almacen     = eval('document.form0.wh').value;
	var familia     = eval('document.form0.familyCode').value;
	var clase       = eval('document.form0.classCode').value;
	if(almacen ==' ') msg=' Almacen';
	if(familia =='') msg+=' , Familia';
	if(clase =='')   msg+=' ,Clase';
	if(msg=='')
	 <%=popUp%>('../common/search_articulo.jsp?id=2&fp=RA&almacen='+almacen+'&familia='+familia+'&clase='+clase);
	else alert('Seleccione '+msg);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%if(!fg.trim().equals("CM")){%>
<%@ include file="../common/menu_base.jsp"%>
<%}%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PARAMETROS PARA REPORTE DE ARTICULOS"></jsp:param>
	</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("descripcion","")%>
			
			<tr class="TextFilter">
				<td width="20%">Departamento</td>
				<td colspan="2"><%=fb.textBox("depto","",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Titulo</td>
				<td colspan="2"><%=fb.textBox("titulo","",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Almac&eacute;n</td>
				<td colspan="2">
				<%=fb.select(ConMgr.getConnection(),"select ' ' optValueColumn,'TODOS' optLabelColumn from dual   union select to_char(codigo_almacen) as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by 1","wh",almacen,false,false,0,null,"T","onChange=\"javascript:loadXML('../xml/familyCode.xml','familyCode','"+familyCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form0.familyCode.value,'KEY_COL','T')\"")%>
				</td>
			</tr>	
			
			
			<tr class="TextFilter">
				<td>Familia</td>
				<td colspan="2">

			Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">loadXML('../xml/familyCode.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%="document.form0.wh.value"%>,'KEY_COL','T');</script> 
		Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%="document.form0.familyCode.value"%>,'KEY_COL','T');</script>
		
		
		
				</td>
			</tr>
			<tr class="TextFilter">
				<td>Anaquel</td>
				<td colspan="2">DESDE  <%=fb.intBox("anaquel","",false,false,false,10)%> &nbsp;&nbsp; HASTA <%=fb.intBox("anaquelHasta","",false,false,false,10)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Articulo</td>
				<td colspan="2"><%=fb.intBox("codigo","",false,false,false,10)%><%=fb.textBox("descArticulo","",false,false,true,60)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaArticulo()\"")%> </td>
			</tr>
			
			
			
			<tr class="TextFilter">
				<td>Tipo de Articulo</td>
				<td colspan="2"><%=fb.select("tipo","N=NORMAL,A=ACTIVO,K =KIT,B=BANDEJA","","T")%></td>
			</tr>
			<tr class="TextFilter">
				<td>Con o Sin Existencia</td>
				<td colspan="2"><%=fb.select("existencia","S=CON EXISTENCIA,N=SIN EXISTENCIA","","")%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Consignacion</td>
				<td colspan="2"><%=fb.select("consignacion","N=NO,S=SI","","")%></td>
			</tr>
			<tr class="TextFilter">
				<td>Tipo de Reporte</td>
				<td colspan="2"><%=fb.select("reporte","C=COMPLETO,F=FILTRADO (CONTABILIDAD)","","")%> Filtrado (Tipo de servicio 02,03,04)  </td>
			</tr>	
			<tr class="TextFilter">
				<td>Periodo</td>	
				<td colspan="2">Mes<%=fb.textBox("mes","",false,false,true,10)%>Año<%=fb.textBox("anio","",false,false,true,10)%> <%=fb.button("buscar1","...",false,false,"","","onClick=\"javascript:buscaPeriodo()\"")%></td>
			</tr>
			
		<tr class="TextFilter" align="center">
			<td colspan="3"><%//=fb.button("buscar","Reporte",false,false,"","","onClick=\"javascript:showReporte()\"")%> </td>
		</tr>
		<tr class="TextRow01"> 
					<td colspan="3"><%=fb.radio("reporte1","RI",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte Inventario</td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="3"><%=fb.radio("reporte1","RC",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte Contabilidad</td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="3"><%=fb.radio("reporte1","RH",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte Historico
                    &nbsp;&nbsp;&nbsp;<a href="javascript:showReporte('RH',3)" class="Link00Bold">Excel</a>
                    </td>
				</tr>
	
	<%=fb.formEnd(true)%>
	<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
		
</td></tr>
		

</table>
</body>
</html>
<%
}//GET
%>
