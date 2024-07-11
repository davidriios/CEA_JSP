<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />
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
SBMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

if (mode == null) mode = "add";
if (fg == null) fg = "FACT";
ArrayList alWh = new ArrayList();
StringBuffer sbSql = new StringBuffer();
sbSql.append("select codigo_almacen as optValueColumn, descripcion||' [ '||codigo_almacen||' ]' as optLabelColumn from tbl_inv_almacen where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by 2");
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

String cdsDet = "N";
try { cdsDet = java.util.ResourceBundle.getBundle("issi").getString("cdsDet"); } catch(Exception e) { System.out.println("Parameter cdsDet not defined!! Using CDS from header..."); }

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Consumo por Centro de Servicio - '+document.title;
function doAction()
{
}

function showReporte(value)
{
  var categoria    ='ALL';
  var area         ='ALL';
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;
  var items     ='ALL';
  var aseguradora ='ALL';
  var wh='ALL';
  var familia='ALL';
  var clase='ALL';
  var tipoServicio='ALL';
  var afectaInv='ALL';
  var soloArt='ALL';
  var status='ALL';
  var keyCargo ='';  
  if(eval('document.form0.serviceType'))if(eval('document.form0.serviceType').value!='')tipoServicio     = eval('document.form0.serviceType').value;
  if(eval('document.form0.aseguradora'))if(eval('document.form0.aseguradora').value!='')aseguradora     = eval('document.form0.aseguradora').value;
  if(eval('document.form0.wh'))if(eval('document.form0.wh').value!='')wh     = eval('document.form0.wh').value;
  if(eval('document.form0.family'))if(eval('document.form0.family').value!='')familia     = eval('document.form0.family').value;
  if(eval('document.form0.iClase'))if(eval('document.form0.iClase').value!='')clase     = eval('document.form0.iClase').value;
  if(eval('document.form0.area'))if(eval('document.form0.area').value!='')area     = eval('document.form0.area').value;
  if(eval('document.form0.categoria'))if(eval('document.form0.categoria').value!='')categoria     = eval('document.form0.categoria').value;
  if(eval('document.form0.items'))if(eval('document.form0.items').value!='')items     = eval('document.form0.items').value;
  if(eval('document.form0.afectaInv'))if(eval('document.form0.afectaInv').value!='')afectaInv     = eval('document.form0.afectaInv').value;
  if(eval('document.form0.soloArt'))if(eval('document.form0.soloArt').value!='')soloArt     = eval('document.form0.soloArt').value;
  if(eval('document.form0.status'))if(eval('document.form0.status').value!='')status = eval('document.form0.status').value;
  if(eval('document.form0.keyCargo'))keyCargo = eval('document.form0.keyCargo').value;  
  
 	var pchObj = eval('document.form0.ctrlHeader');	
    var pch    = "false";

	if(value=="1")
	{
	if(fechaini!=''&&fechafin!='') 
	{
	  	if (pchObj.checked == true) pch = "true";	
        {
		var mostrarCosto = "N";
		if(eval('document.form0.mostrarCosto')){if(eval('document.form0.mostrarCosto').checked == true)mostrarCosto = "S";}
		
		 abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_fact_consumo_x_item.rptdesign&p_categoria='+categoria+'&p_centro_servicio='+area+'&p_tipo_servicio='+tipoServicio+'&fdesde='+fechaini+'&fhasta='+fechafin+'&p_item='+items+'&p_aseguradora='+aseguradora+'&p_wh='+wh+'&p_familia='+familia+'&p_clase='+clase+'&p_soloArt='+soloArt+'&p_afectaInv='+afectaInv+'&pCtrlHeader='+pch+'&p_fg=<%=fg%>&pCdsDet=<%=cdsDet%>&pKeyCargo='+keyCargo+'&pCosto='+mostrarCosto);			
		}     
	}else CBMSG.warning('Seleccione Rango de Fecha para el reporte!!');
  }
  else
  if(value=="2")
	{
	if(fechaini!=''&&fechafin!='') 
	{
	  	if (pchObj.checked == true) pch = "true";	
        {
		 abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_fact_consumo_x_paciente.rptdesign&p_categoria='+categoria+'&p_centro_servicio='+area+'&p_tipo_servicio='+tipoServicio+'&fdesde='+fechaini+'&fhasta='+fechafin+'&p_item='+items+'&p_aseguradora='+aseguradora+'&p_wh='+wh+'&p_familia='+familia+'&p_clase='+clase+'&p_soloArt='+soloArt+'&p_afectaInv='+afectaInv+'&pCtrlHeader='+pch+'&p_fg=<%=fg%>&pCdsDet=<%=cdsDet%>&pKeyCargo='+keyCargo+'&pStatus='+status);			
		}     
	}else CBMSG.warning('Seleccione Rango de Fecha para el reporte!!');
  }

}
function selItems()
{
 	var cds    = eval('document.form0.area').value;
	var ts    = eval('document.form0.serviceType').value;
	//if(cds !='')
	abrir_ventana2('../common/sel_items_x_centro.jsp?cs='+cds+'&tipoServicio='+ts);
	//else alert ('Seleccione Centro de Servicio');

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR CENTRO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>

<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter">
				    <td width="40%" align="right">Centro de Servicio</td>
					<td width="60%">
          <%//=fb.select(ConMgr.getConnection(),"select distinct b.codigo, '['||b.codigo||'] '||b.descripcion from tbl_cds_servicios_x_centros a, tbl_cds_centro_servicio b where a.centro_servicio=b.codigo order by b.codigo","area",area,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/cdsService.xml','serviceType','"+tipoServicio+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"","","T")%>
		            <%=fb.select(ConMgr.getConnection(),"select distinct b.codigo, '['||b.codigo||'] '||b.descripcion from tbl_cds_servicios_x_centros a, tbl_cds_centro_servicio b where a.centro_servicio=b.codigo and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by b.codigo","area",area,false,false,0,null,null,"","","S")%>

					<!--<script language="javascript">
						loadXML('../xml/cdsService.xml','serviceType','<%=tipoServicio%>','VALUE_COL','LABEL_COL','<%=area%>','KEY_COL','S');
					</script>-->
					
          </td>
				</tr>
        		<tr class="TextFilter">
				   <td align="right">Tipo de Servicio</td>
				   <td ><%=fb.select(ConMgr.getConnection(),"select distinct b.codigo, '['||b.codigo||'] '||b.descripcion from tbl_cds_tipo_servicio b where compania="+(String)session.getAttribute("_companyId")+" order by b.codigo","serviceType",tipoServicio,false,false,0,null,null,"","","S")%><%//=fb.select("serviceType","","")%></td>
				</tr>
				<%if(fg.trim().equals("INV")){%>
				<tr class="TextFilter">
					<td align="right">Almac&eacute;n</td>
					<td><%=fb.select("wh",alWh,"",false,false,false,0,"Text10","","","","T")%></td>
				</tr>
				<tr class="TextFilter">
					<td align="right">Familia</td>
					<td><%=fb.select("family","","",false,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','iClass','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');\"")%>
						<script language="javascript">loadXML('../xml/itemFamily.xml','family','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>','KEY_COL','T');</script>
					</td>
				</tr>
				<tr class="TextFilter">
					<td align="right">Clase</td>
					<td>
						<%=fb.select("iClass","","",false,false,false,0,"Text10",null,null)%>
						<script>language="javascript">loadXML('../xml/itemClass.xml','iClass','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+document.form0.family.value,'KEY_COL','T');</script>
					</td>
				</tr>
				
				<%=fb.hidden("soloArt","Y")%>
				
				<%}%>
				
				
				<tr class="TextFilter">
					<td align="right">Afecta Inventario</td>
					<td><%=fb.select("afectaInv","Y=SI,N=NO","",false,false,false,0,"Text10","","","","T")%></td>
				</tr>				
				
				<%if(!fg.trim().equals("INV")){%>	
				<tr class="TextFilter">
					<td align="right">Articulo de Inventario</td>
					<td><%=fb.select("soloArt","Y=SI,N=NO","",false,false,false,0,"Text10","","","","T")%></td>
				</tr>
			  	<tr class="TextFilter" >
				   <td align="right">Categor&iacute;a</td>
				   <td>
		<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
				   </td>
			  	</tr>
        		<tr class="TextFilter">
					<td align="right">Aseguradora</td>
					<td><%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora",aseguradora,"T")%></td>
				</tr>
				<%}%>
        		<tr class="TextFilter">
					<td align="right">Items</td>
					<td>
					<%=fb.hidden("keyCargo","")%>
					<%=fb.intBox("items","",false,false,false,10)%>
					<%=fb.textBox("descripcion","",false,false,true,40)%>
					<%=fb.button("btnItems","...",true,false,null,null,"onClick=\"javascript:selItems();\"")%></td>
				</tr>
				<tr class="TextFilter" >
				   <td align="right">Fecha</td>
				   <td>
			 &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
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
			    <td>Esconder Cabecera (Excel)</td>
				<td><%=fb.checkbox("ctrlHeader","",false,false,"","","","")%></td>
			  </tr>
			  <authtype type='52'>
			  <tr class="TextFilter">
			    <td colspan="2">&nbsp;&nbsp;Mostrar Costo(Solo para reporte de Consumo por Item):<%=fb.checkbox("mostrarCosto","",false,false,"","","","")%></authtype></td>
			  </tr>			  
			  </authtype>
			</table>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="3">REPORTES</td>
				</tr>

				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="3"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Consumo por Item</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3">
					<%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Consumo por Cuenta  (Paciente/Admision)
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado
					<%=fb.select("status","I=Inactiva,A=Activa,E=En Espera","","T")%>
					</td>
				</tr>
				</authtype>

<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
%>
