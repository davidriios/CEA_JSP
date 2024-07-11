<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.io.*"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200025") || SecMgr.checkAccess(session.getId(),"200026") || SecMgr.checkAccess(session.getId(),"200027") || SecMgr.checkAccess(session.getId(),"200028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String wh = request.getParameter("wh");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String fechafin = request.getParameter("fechafin");
String fechaini = request.getParameter("fechaini");
String existencia = request.getParameter("existencia");
String cantidad = request.getParameter("cantidad");
String fg = request.getParameter("fg");
if(fg == null) fg = "HA" ;


if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "select i.art_familia value_col, i.art_familia||' - '||a.nombre as label_col, i.art_familia as title_col, i.compania||'-'||i.codigo_almacen as key_col from (select distinct compania, art_familia, codigo_almacen from tbl_inv_inventario where compania="+(String) session.getAttribute("_companyId")+") i, tbl_inv_familia_articulo a where i.compania=a.compania(+) and i.art_familia=a.cod_flia(+) order by i.compania,i.codigo_almacen, i.art_familia asc";
		XMLCreator xc = new XMLCreator(ConMgr);
		 xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"familyCode.xml",sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inventario - Articulos - '+document.title;
function showReporte1(format)
{
	
	var msg ='';
	<%
	if(!fg.trim().equals("VP") && !fg.trim().equals("AML") && !fg.trim().equals("RCP")){
	%>
	var depto       = eval('document.form1.depto').value;
	var titulo      = eval('document.form1.titulo').value;
	<%}%>
	var wh     = eval('document.form1.wh').value;
	var familia     = eval('document.form1.familyCode').value;
	var clase       = eval('document.form1.classCode').value;
	var id       	= eval('document.form1.code').value;
	
	<%
	if(fg.trim().equals("PR") || fg.trim().equals("AC") || fg.trim().equals("LI")){
	%>
	var tipo       = eval('document.form1.tipo').value;
	var fp       	= eval('document.form1.fp').value;
	<%
	}
	%>
	var subclase = '';
	if( eval('document.form1.subclassCode')) subclase = eval('document.form1.subclassCode').value;
	<%
	if(fg.trim().equals("AC")){
	%>
	abrir_ventana('../inventario/print_articulos_consignacion.jsp?articulo='+id+'&depto='+depto+'&familyCode='+familia+'&classCode='+clase+'&almacen='+wh+'&tipo='+tipo+'&fg='+fp+'&titulo='+titulo);
	<%
	}else if(fg.trim().equals("PR")){
	%>
	var venta       = eval('document.form1.venta').value;
	var consignacion       	= eval('document.form1.consignacion').value;
	var estado       = eval('document.form1.estado').value;
	if(format=='rpt')abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/articulo_precio_costo.rptdesign&pAlmacen='+wh+'&pFamilia='+familia+'&pTipoArt='+tipo+'&pArtVenta='+venta+'&pArtConsignacion='+consignacion+'&pEstado='+estado);
	else abrir_ventana('../inventario/print_articulos_precio_costo.jsp?venta='+venta+'&depto='+depto+'&familyCode='+familia+'&consignacion='+consignacion+'&almacen='+wh+'&tipo='+tipo+'&fg='+fp+'&titulo='+titulo+'&estado='+estado);
	<%
	}else if(fg.trim().equals("VP")){
	%>
	var oper_variacion       = eval('document.form1.oper_variacion').value;
	var variacion       	= eval('document.form1.variacion').value;
	if(variacion==0) alert('Introduzca porcentaje de variación!');
	else abrir_ventana('../inventario/print_variacion_precio.jsp?familia='+familia+'&clase='+clase+'&codigo='+id+'&almacen='+wh+'&operador='+oper_variacion+'&variacion='+variacion);
	<%
	}else if(fg.trim().equals("AML")){
	%>
	var fecha       = eval('document.form1.fechafin').value;	
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_inv_mov_lento.rptdesign&paramAlmacen='+wh+'&paramFamilia='+familia+'&paramClase='+clase+'&paramArticulo='+id+'&paramFecha='+fecha);
	<%
	}else if(fg.trim().equals("RCP")){
	%>
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_inv_revision_costo_promedio.rptdesign&almacen='+wh+'&familia='+familia+'&clase='+clase+'&articulo='+id);
	<%
	} else{
	%>
	var conta= eval('document.form1.conta').value;
	var inv= eval('document.form1.inventario').value;
		abrir_ventana('../inventario/print_articulos_list.jsp?articulo='+id+'&depto='+depto+'&familyCode='+familia+'&classCode='+clase+'&almacen='+wh+'&tipo='+tipo+'&fg='+fp+'&titulo='+titulo+'&subclase='+subclase+'&afectaConta='+conta+'&afectaInv='+inv);
	<%
	}
	%>
}
function showReporte(opt)
{
	var msg ='';
	var almacen     = eval('document.form1.wh').value;
	var familia     = eval('document.form1.familyCode').value;
	var clase       = eval('document.form1.classCode').value;
	var id       	= eval('document.form1.code').value;
	if(clase =='')  eval('document.form1.clase').value;
	var fechafin       = eval('document.form1.fechafin').value;
	var fechaini       = eval('document.form1.fechaini').value;
	var fecha_corrida  = eval('document.form1.fecha_corrida').value;
	var titulo  	   = eval('document.form1.titulo').value;
	var subclase = '';
	if(eval('document.form1.subclassCode').value) subclase = eval('document.form1.subclassCode').value;
    var tipoMov = '';
	if(document.getElementById("tipo_mov"))tipoMov=document.getElementById("tipo_mov").value || "";

	if(almacen ==' ') msg=' Almacen';
	if(familia =='') msg+=' , Familia';
	if(clase =='')   msg+=' , Clase';
	if(id =='')   msg+=' , Articulo';
	
	if(msg==''){
	if(opt==1)
		abrir_ventana('../inventario/print_historia_mov_articulo.jsp?mode=edit&id='+id+'&fecha_corrida='+fecha_corrida+'&familyCode='+familia+'&classCode='+clase+'&wh='+almacen+'&tDate='+fechafin+'&fDate='+fechaini+'&titulo='+titulo)+'&subclase='+subclase;
		else abrir_ventana('../inventario/print_historia_mov_articulo_doc2.jsp?mode=edit&id='+id+'&fecha_corrida='+fecha_corrida+'&familyCode='+familia+'&classCode='+clase+'&wh='+almacen+'&tDate='+fechafin+'&fDate='+fechaini+'&titulo='+titulo+'&subclase='+subclase+'&tipo_mov='+tipoMov);
		}
	else alert('Seleccione '+msg);
}

function buscaArticulo()
{
	var msg ='';
	var almacen     = eval('document.form1.wh').value;
	var familia     = eval('document.form1.familyCode').value;
	var clase       = eval('document.form1.classCode').value;
	var subclase = '';
	if(eval('document.form1.subclassCode').value) subclase = eval('document.form1.subclassCode').value;
	if(almacen ==' ') msg=' Almacen';
	//if(familia =='') msg+=' , Familia';
	//if(clase =='')   msg+=' ,Clase';
	if(msg==''){
	<%if(fg.trim().equals("HA")){%>
	 abrir_ventana('../common/search_articulo.jsp?id=4&fp=RHA&almacen='+almacen+'&familia='+familia+'&clase='+clase+'&subclase='+subclase);
	 <%}else{%>
	 abrir_ventana('../common/search_articulo.jsp?id=5&fp=RAC&almacen='+almacen+'&familia='+familia+'&clase='+clase);
	 <%}%>
	}else alert('Seleccione '+msg);
}
function cargarClase()
{
var clase = eval('document.form1.clase').value;
var flia = eval('document.form1.familyCode').value;
loadXML('../xml/itemClass.xml','classCode',clase,'VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+flia,'KEY_COL','S');
eval('document.form1.clase').value="";
clearArt();
}					 
function clearArt()
{
eval('document.form1.code').value="";
eval('document.form1.name').value="";
}					 

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("HA")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REPORTE - ARTICULOS HISTORIA DE COMPRA"></jsp:param>
</jsp:include>
<%}else if(fg.trim().equals("AC")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REPORTE - ARTICULOS A CONSIGNACION"></jsp:param>
</jsp:include>
<%}else if(fg.trim().equals("LI")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REPORTE - LISTADO DE ARTICULOS "></jsp:param>
</jsp:include>
<%}else{%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REPORTE - ARTICULOS "></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
  <tr>
    <td colspan="3" align="right">&nbsp;</td>
  </tr>
  <!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
  <%fb = new FormBean("form1",request.getContextPath()+"/common/urlRedirect.jsp");%>
  <%=fb.formStart()%> 
	<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
	<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
	<%=fb.hidden("clase",""+classCode)%>
  <%
	if(fg.trim().equals("AC") || fg.trim().equals("LI") || fg.trim().equals("PR")){//LI = listado de articulos por almacen inv0037 PR = PRECIO <= COSTO %>
  <tr class="TextFilter">
    <td width="15%">Departamento</td>
    <td width="85%"><%=fb.textBox("depto","",false,false,false,60)%></td>
  </tr>
  <%
	}
	%>
  <%
	if(!fg.trim().equals("VP") && !fg.trim().equals("AML") && !fg.trim().equals("RCP")){
	%>
	<tr class="TextFilter">
    <td width="15%">Titulo</td>
    <td width="85%"><%=fb.textBox("titulo","",false,false,false,60)%></td>
  </tr>
  <%
	}
	%>
  <%
	if(fg.trim().equals("PR")){
	%>
  <%=fb.hidden("classCode","")%> 
	<%=fb.hidden("code","")%> <%=fb.hidden("fp","")%>
  <tr class="TextFilter">
    <td width="15%"> Almac&eacute;n</td>
    <td width="85%"><%=fb.select(ConMgr.getConnection(),"select to_char(codigo_almacen) as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by 1","wh",wh,false,false,0,"Text10",null,"",null,"T")%></td>
  </tr>
  <tr class="TextFilter">
    <td>Familia</td>
    <td><%=fb.select("familyCode","","",false,false,0,"Text10",null,"")%>
      <script language="javascript">loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','S');</script>
    </td>
  </tr>
  <tr class="TextFilter">
    <td width="15%">Tipo de Articulo</td>
    <td width="85%"><%=fb.select("tipo","N=NORMAL,A=ACTIVO,K=KIT,B=BANDEJA","","S")%></td>
  </tr>
  <tr class="TextFilter">
    <td width="15%">Venta</td>
    <td width="85%"><%=fb.select("venta","S=SI,N=NO","","S")%></td>
  </tr>
  <tr class="TextFilter">
    <td width="15%">Consignacion</td>
    <td width="85%"><%=fb.select("consignacion","S=SI,N=NO","","S")%></td>
  </tr>
  <tr class="TextFilter">
    <td width="15%">Estado</td>
    <td width="85%"><%=fb.select("estado","A=ACTIVO,I=INACTIVO","","S")%></td>
  </tr>
  <tr class="TextFilter">
    <td>&nbsp;</td>
    <td>
			<%=fb.button("buscar","Reporte",false,false,"","","onClick=\"javascript:showReporte1()\"")%>
			<%=(fg.equalsIgnoreCase("PR"))?fb.button("buscar","EXCEL",false,false,"","","onClick=\"javascript:showReporte1('rpt')\""):""%>
		</td>
  </tr>
   <%
	}if(!fg.trim().equals("PR")){
	%>
  <tr class="TextFilter">
    <td width="15%"> Almac&eacute;n</td>
    <td width="85%"><%=fb.select(ConMgr.getConnection(),"select to_char(codigo_almacen) as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by 1","wh",wh,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/familyCode.xml','familyCode','"+familyCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form1.familyCode.value,'KEY_COL','T')\"","",(fg.equals("AML")?"T":""))%> </td>
  </tr>
  <tr class="TextFilter">
    <td>Familia</td>
    <td><%=fb.select("familyCode","","",false,false,0,"Text10",null,"onChange=\"javascript:cargarClase()\"")%>
      <script language="javascript">loadXML('../xml/familyCode.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(wh != null && !wh.equals(""))?wh:"document.form1.wh.value"%>,'KEY_COL','S');</script>
    </td>
  </tr>
  <tr class="TextFilter">
    <td> Clase </td>
    <td><%=fb.select("classCode","","",false,false,0,"Text10",null,"onChange=\"javascript:clearArt();loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form1.familyCode.value+'-'+this.value,'KEY_COL','T')\"")%>
      <script language="javascript">loadXML('../xml/itemClass.xml','classCode','document.form1.clase.value','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form1.familyCode.value"%>,'KEY_COL','S');</script>
      <%if(!fg.equals("AML")){%>Subclase: <%=fb.select("subclassCode","","",false,false,0,"text10",null,"onChange=\"javascript:clearArt();\"")%>
      <script language="javascript">
    loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-<%=(familyCode != null && !familyCode.equals(""))?familyCode:"document.form1.familyCode.value"%>-<%=(classCode != null && !classCode.equals(""))?classCode:"document.form1.classCode.value"%>','KEY_COL','T');
    </script><%}%>
    </td>
  </tr>
  <tr class="TextFilter">
    <td> Articulo </td>
    <td><%=fb.textBox("code","",false,false,(fg.trim().equals("LI"))?false:true,10,"Text10",null,null)%> <%=fb.textBox("name","",false,false,true,50,"Text10",null,null)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaArticulo()\"")%> </td>
  </tr>
  <%if(!fg.trim().equals("LI") && !fg.trim().equals("RCP")){%>
  <tr class="TextFilter">
    <td>Tipo Doc.</td>
    <td><%=fb.select("tipo_mov","DEV. ALM=DEV. ALM,ENT. UND=ENT. UND,ENT. TRF ALM=ENT. TRF ALM,TRF. ALM.=TRF. ALM.,ENT. PAC,DEV. PROV=DEV. PROV,OTROS CARGOS=OTROS CARGOS,RECEP=RECEP,DEV. UND=DEV. UND,DEV. PAC=DEV. PAC,AJ. CORR=AJ. CORR,AJ. OTROS","","S")%></td>
  </tr><%}%>
   
  <%
	}
	if(fg.trim().equals("HA")){
	%>
  <tr class="TextFilter">
    <td> Fecha </td>
    <td><jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fechaini" />
		<jsp:param name="valueOfTBox1" value="" />
		<jsp:param name="nameOfTBox2" value="fechafin" />
		<jsp:param name="valueOfTBox2" value="" />
		</jsp:include>
    </td>
  </tr>
  <tr class="TextFilter">
    <td  bgcolor="#FFCC00" ><font color="#000000" > Fecha de Ultimo inventario Fisico</font> </td>
    <td><%=fb.textBox("fecha_corrida","",false,false,true,20,"Text10",null,null)%> </td>
  </tr>
  <!--<tr class="TextFilter">
    <td>&nbsp;</td>
    <td><%//=fb.button("buscar","Reporte",false,false,"","","onClick=\"javascript:showReporte(1)\"")%> </td>
  </tr>-->
  <tr class="TextFilter">
    <td>&nbsp;</td>
    <td><%=fb.button("buscar","Reporte Por Fecha y Tipo Doc",false,false,"","","onClick=\"javascript:showReporte(2)\"")%></td>
  </tr>
  <%}%>
	<%
	if(fg.trim().equals("AML")){
	%>
  <tr class="TextFilter">
    <td> Fecha </td>
    <td><jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fechafin" />
		<jsp:param name="valueOfTBox1" value="" />
		</jsp:include>
    </td>
  </tr>
  <%}%>
  <%if(fg.trim().equals("AC") || fg.trim().equals("LI") || fg.trim().equals("AML")){
		if(!fg.trim().equals("AML")){%>
  <tr class="TextFilter">
    <td width="15%">Tipo de Articulo</td>
    <td width="85%"><%=fb.select("tipo","N=NORMAL,A=ACTIVO,K=KIT,B=BANDEJA","","S")%></td>
  </tr>
  <tr class="TextFilter">
    <td width="15%">Con O Sin Existencia</td>
    <td width="85%"><%=fb.select("fp","CE=CON EXISTENCIA ,SE=SIN EXISTENCIA","",(fg.trim().equals("LI"))?"S":"")%></td>
  </tr>
  <%if(fg.trim().equals("LI")){%>
  <tr class="TextFilter">
    <td width="15%">Afecta Inv:</td>
    <td width="85%"><%=fb.select("inventario","Y=SI,N=NO","","S")%></td>
  </tr>
  <tr class="TextFilter">
    <td width="15%">Afecta Conta:</td>
    <td width="85%"><%=fb.select("conta","Y=SI,N=NO","","S")%></td>
  </tr>
	<%}}%>
  <tr class="TextFilter">
    <td>&nbsp;</td>
    <td><%=fb.button("buscar","Reporte",false,false,"","","onClick=\"javascript:showReporte1()\"")%> </td>
  </tr>
  <%}%>
  <%if(fg.trim().equals("VP")){%>
  <tr class="TextFilter">
    <td width="15%">Variaci&oacute;n</td>
    <td width="85%"><%=fb.select("oper_variacion","L=<,E=&#61,M=>","","")%><%=fb.textBox("variacion","",false,false,false,4,"",null,null)%>&#37;</td>
  </tr>
  <tr class="TextFilter">
    <td>&nbsp;</td>
    <td><%=fb.button("buscar","Reporte",false,false,"","","onClick=\"javascript:showReporte1()\"")%></td>
  </tr>
  <%}%>
	<%if(fg.equals("RCP")){%>
  <tr class="TextFilter">
    <td>&nbsp;</td>
    <td><%=fb.button("buscar","Reporte",false,false,"","","onClick=\"javascript:showReporte1()\"")%></td>
  </tr>
  <%}%>

  <%=fb.formEnd()%>
  <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>

