<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.contabilidad.ActivosFijos"%>
<%@ page import="issi.contabilidad.Activos"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iActivo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ACTMgr" scope="page" class="issi.contabilidad.ActivoFijoMgr" />
<%
/**
==========================================================================================
fg = "RA";// edicion  de activos
fg = "RAC";//registro  de activos
fg = "CEA" consulta de activos entregados
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted estï¿½ fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ACTMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTipo = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdoParam = new CommonDataObject();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String compania =  (String) session.getAttribute("_companyId");
String userName = UserDet.getUserName();
String fechafin = request.getParameter("fechafin");
String fechaini = request.getParameter("fechaini");
String unidad = request.getParameter("unidad");
String change = request.getParameter("change");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String articulo = request.getParameter("articulo");
String descUnd = request.getParameter("descUnd");
String placa = request.getParameter("placa");
String articuloDesc = request.getParameter("articuloDesc");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;

int activoLastLineNo = 0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (fg == null) fg = "RA";//registro y edicion  de activos

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (unidad == null) unidad = "";
if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";
if (articulo == null) articulo = "";
if (descUnd == null) descUnd = "";
if (placa == null) placa = "";
if (articuloDesc == null) articuloDesc = "";

if (!unidad.trim().equals("")) appendFilter += " and a.ue_codigo="+unidad;
if (!familyCode.trim().equals("")) appendFilter += " and a.cod_flia ="+familyCode;
if (!classCode.trim().equals("")) appendFilter += " and a.cod_clase ="+classCode;
if (!articulo.trim().equals("")) appendFilter += " and a.cod_articulo ="+articulo;
if (!articuloDesc.trim().equals("")) appendFilter += " and ar.descripcion  like '%"+articuloDesc+"%'";
if (!placa.trim().equals("")) appendFilter += " and a.placa  like '%"+placa+"%'";
if (!fechaini.trim().equals("") && !fechafin.trim().equals("")) appendFilter += " and to_date(to_char(a.fecha_de_entrada ,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fechaini+"','dd/mm/yyyy') and to_date('"+fechafin+"','dd/mm/yyyy')";

if (request.getParameter("activoLastLineNo") != null) activoLastLineNo = Integer.parseInt(request.getParameter("activoLastLineNo"));

if(fg.trim().equals("RAC"))
{
/*
sql = "select codigo_detalle as value_col, codigo_detalle||' - '||descripcion as label_col,codigo_detalle  title_col,cod_compania ||'-'||codigo_detalle key_col from tbl_con_detalle_otro where cod_compania = "+(String) session.getAttribute("_companyId")+" order by codigo_detalle ";
		XMLCreator xc = new XMLCreator(ConMgr);
		 xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"detalleCuenta.xml",sql);
*/


}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	alTipo = sbb.getBeanList(ConMgr.getConnection(),"select codigo_entrada as optValueColumn, codigo_entrada||' - '||descripcion as optLabelColumn, codigo_entrada as optTitleColumn from tbl_con_tipo_entrada order by 2",CommonDataObject.class);
	sql = "select column_value as familia from table( select split((select get_sec_comp_param( "+(String) session.getAttribute("_companyId")+",'FLIA_ACTIVO') from dual ),',') from dual  )";
  cdoParam = (CommonDataObject) SQLMgr.getData(sql);
if(cdoParam !=null){if (familyCode.trim().equals(""))familyCode=cdoParam.getColValue("familia"); }

	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (change == null)
	{
		iActivo.clear();

		if(!appendFilter.trim().equals(""))
		{
		if(!fg.trim().equals("CEA")) appendFilter +=" and a.estado = 'P' ";

		sql=" select x.*,to_char(x.fecha_de_entrada,'dd/mm/yyyy') fechaDeEntrada, to_char(x.fechaCreax,'dd/mm/yyyy hh12:mi:ss am') fechaCrea,to_char(x.fechaCreaActivox,'dd/mm/yyyy hh12:mi:ss am') fechaCreaActivo, to_char(x.finalGarantiax,'dd/mm/yyyy') finalGarantia,  to_char(x.fechaAnulaActivox,'dd/mm/yyyy hh12:mi:ss am')  fechaAnulaActivo,'U' status, case when trunc(x.fecha_de_entrada) >= to_date('01-06-2007','DD-MM-YYYY')  then x.placaNew else null end as placaNueva, case when trunc(x.fecha_de_entrada) >= to_date('01-06-2007','DD-MM-YYYY')  then null else x.placaNew end as placa from ( select  a.secuencia, a.compania, a.ue_codigo ueCodigo,   a.entrada_codigo entradaCodigo, a.cuentah_activo cuentahActivo, a.cuentah_espec cuentahEspec,  a.cuentah_detalle cuentahDetalle, (select w.descripcion from tbl_con_detalle_otro w where w.cod_compania =a.compania and w.codigo_detalle = a.cuentah_detalle) descDetalle, a.fecha_de_entrada, a.estatus,  a.tipo_activo tipoActivo, a.tipo_de_depre tipoDeDepre, nvl(a.valor_deprem,0) valorDeprem,  a.valor_inicial valorInicial, a.valor_rescate valorRescate, nvl(a.valor_actual,0) valorActual, a.nivel_codigo_ubic nivelCodigoUbic, a.orden__compra ordenCompra, nvl(a.acum_deprec,0) acumDeprec,  nvl(a.valor__mejor_acum,0) valorMejorAcum, nvl(a.valor_mejora_actual,0) valorMejoraActual, nvl(a.valor_depre_mejora ,0) valorDepreMejora,  nvl(a.acum_deprem,0) acumDeprem, nvl(a.meses_depre_act,0) mesesDepreAct, a.cod_provee codProvee,  a.observacion, a.vida_estimada vidaEstimada, a.final_garantia finalGarantiax,  a.cond_fisica condFisica, a.usua_crea usuaCrea, a.usua_mod usuaMod, a.fecha_crea fechaCreax, a.fecha_mod fechaMod, a.cod_clasif codClasif,   a.npoliza, a.factura, a.cod_articulo codArticulo,  a.cod_clase codClase, a.cod_flia codFlia,a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo codigoArticulo  , a.placa placaNew,  a.anio, a.no_entrega noEntrega, a.estado, a.usuario_crea_activo usuarioCreaActivo, a.fecha_crea_activo fechaCreaActivox, a.usuario_anula_activo usuarioAnulaActivo, a.fecha_anula_activo fechaAnulaActivox, a.numero_serie numeroSerie, a.comentario,  a.secuencia_placa secuenciaPlaca, b.nombre_proveedor descProveedor,nvl(ue.descripcion,' ') descUnidad ,ar.descripcion descArticulo ,te.descripcion descEntrada, ce.descripcion cuentaDesc from tbl_con_temp_activo a,tbl_com_proveedor  b ,tbl_sec_unidad_ejec ue, tbl_inv_articulo ar,tbl_con_tipo_entrada te, tbl_con_especificacion ce  where  a.compania = "+(String) session.getAttribute("_companyId")+"  and a.cod_provee = b.cod_provedor(+) and a.ue_codigo = ue.codigo(+) and a.compania = ue.compania(+) and a.cod_flia = ar.cod_flia and a.cod_clase = ar.cod_clase and a.cod_articulo = ar.cod_articulo and a.compania = ar.compania and a.entrada_codigo = te.codigo_entrada(+) and a.cuentah_activo = ce.cta_control(+) and a.cuentah_espec = codigo_espec(+) and a.compania = ce.compania(+) "+appendFilter+" order by a.fecha_de_entrada desc,a.secuencia desc )x ";

		al  = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal,ActivosFijos.class);

		rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

			activoLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				//cdo = (CommonDataObject) al.get(i);
				ActivosFijos obj = (ActivosFijos) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;

				obj.setKey(key);

				try
				{
					iActivo.put(key, obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		//}
		/*if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.addColValue("secuencia","0");

			activoLastLineNo++;
			if (activoLastLineNo < 10) key = "00" + activoLastLineNo;
			else if (activoLastLineNo < 100) key = "0" + activoLastLineNo;
			else key = "" + activoLastLineNo;
			cdo.addColValue("key",key);

			try
			{
				iActivo.put(key, cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}*/
		}// if appendeFilter
	}//change=null


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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inventario - '+document.title;

function buscaUnd(k){abrir_ventana('../inventario/sel_unid_ejec.jsp?fg=RA&index='+k);}
function displayDet(k,fg){var obj=document.getElementById('detalle'+k);if(obj.style.display=='none'){obj.style.display='';}else {if(fg!='CH'){obj.style.display='none';}}}
function buscaCtaDetalle(k){abrir_ventana('../activos/sel_detalle_cuenta.jsp?fg=<%=fg%>&index='+k);}
function buscaProv(k){abrir_ventana('../inventario/sel_proveedor.jsp?fp=RA&index='+k);}
function showArea(){abrir_ventana1('../inventario/sel_unid_ejec.jsp?fg=RAE');}
function changeDesc(){eval('document.search00.descUnd').value='';}
function buscaArt(k){familia = eval('document.search00.familyCode').value;clase   = eval('document.search00.classCode').value;abrir_ventana('../common/search_articulo.jsp?fp=activosTemp&id=3&index='+k+'&familia='+familia+'&clase='+clase);}
function buscaCta(k){abrir_ventana('../common/search_especificacion.jsp?fg=RAC&index='+k);}
function aplicarVal()
{
	var orden00 = eval('document.form1.orden00').value;
	var factura00   = eval('document.form1.factura00').value;
	var cod_provee00 = eval('document.form1.cod_provee00').value;
	var desc_proveedor00   = eval('document.form1.desc_proveedor00').value;
	var vida_estimada00 = eval('document.form1.vida_estimada00').value;
	var final_garantia00   = eval('document.form1.final_garantia00').value;

	var x = 0;
	var size = parseInt(document.form1.size.value);
	<%for (int i=1; i<=iActivo.size(); i++)
	{%>
		if(document.form1.check<%=i%>.checked)
		{
			 document.form1.orden__compra<%=i%>.value = orden00;
			 document.form1.factura<%=i%>.value = factura00;
			 document.form1.cod_provee<%=i%>.value =cod_provee00;
			 document.form1.desc_proveedor<%=i%>.value = desc_proveedor00;
			 if(vida_estimada00!='')document.form1.vida_estimada<%=i%>.value = vida_estimada00;
			 document.form1.final_garantia<%=i%>.value = final_garantia00;
		}
	<%}%>

}
function aplicarValCon()
{
	var cuentah_activo = eval('document.form1.cuentah_activo00').value;
	var cuentah_espec   = eval('document.form1.cuentah_espec00').value;
	var cuenta_desc   = eval('document.form1.cuenta_desc00').value;

	var cuentah_detalle   = eval('document.form1.cuentah_detalle00').value;
	var desc_detalle   = eval('document.form1.desc_detalle00').value;

	var vida_estimada = eval('document.form1.vida_estimada00').value;

	var fechaEntrada = '';
	var x = 0;
	var size = parseInt(document.form1.size.value);
	<%for (int i=1; i<=iActivo.size(); i++)
	{%>
		if(document.form1.check<%=i%>.checked)
		{

			 // calcular final garantia
			 fechaEntrada = eval('document.form1.fecha_entrada<%=i%>').value;
			 if (vida_estimada!=''&&fechaEntrada!='')
			 {
			 		//**********************************
			 		finalGarantia =  getDBData('<%=request.getContextPath()%>','fn_con_final_garantia( \''+fechaEntrada+'\', '+vida_estimada+') finalGarantia ','dual','','')
			 		//alert('Final Garantia='+finalGarantia);
			 		if (finalGarantia!='') 	document.form1.final_garantia<%=i%>.value = finalGarantia;
			 }


			 document.form1.cuentah_activo<%=i%>.value = cuentah_activo;
			 document.form1.cuentah_espec<%=i%>.value = cuentah_espec;
			 document.form1.cuenta_desc<%=i%>.value = cuenta_desc;

			 document.form1.cuentah_detalle<%=i%>.value = cuentah_detalle;
			 document.form1.desc_detalle<%=i%>.value = desc_detalle;

			 document.form1.vida_estimada<%=i%>.value = vida_estimada;

		}
	<%}%>

}

function validaFecha(k)
{
var rCount = parseInt(eval('document.form1.rCount').value);

var msg='';
if(eval('document.form1.checkActivo'+k).checked)
{
	displayDet(k,'CH');
		<%if(fg.trim().equals("RAC")){%>
	if(eval('document.form1.cuentah_activo'+k))eval('document.form1.cuentah_activo'+k).className='Text10 FormDataObjectRequired';
	if(eval('document.form1.cuentah_detalle'+k))eval('document.form1.cuentah_detalle'+k).className='Text10 FormDataObjectRequired';
	<%}%>
	

	
	
	if(eval('document.form1.fecha_entrada'+k).value =='')
	{
		msg +=' \n- fecha de Entrada';
	}
	if(eval('document.form1.vida_estimada'+k).value =='')
	{
		msg +='\n- Vida Util ';
	}
	<%if(!fg.trim().equals("RA")){%>
		if(eval('document.form1.valor_inicial'+k).value =='')
		{
		msg +='\n- Valor Inicial. ';
		}<%}%>

 if(msg !='')
 {
		alert('El activo no tiene: '+msg+' .. ');
	eval('document.form1.checkActivo'+k).checked = false;
	if(rCount>0)rCount --;
 }else rCount++;

}//
else{ if(rCount>0){rCount --;}displayDet(k,'OT');	
	<%if(fg.trim().equals("RAC")){%>
	if(eval('document.form1.cuentah_activo'+k))eval('document.form1.cuentah_activo'+k).className='';
	if(eval('document.form1.cuentah_detalle'+k))eval('document.form1.cuentah_detalle'+k).className='';
	<%}%>
}
eval('document.form1.rCount').value = rCount;
}

function cargarActivos()
{
var size = parseInt(eval('document.form1.rCount').value);
if(size>0){
return true;}
else {alert('No ha Seleccionado ningun Articulo');
return false;}
}
function doEnviar(fName,action)
{
 document.form1.baction.value = action;
 if(cargarActivos()){
 if(form1Validation()){ 
  document.form1.submit();}else return false;}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
async function removeItem(secuencia, index) {
	let compania = <%=compania%>;
	let articulo = document.getElementById("articulo"+index);
	let detalle = document.getElementById("detalle"+index);
	let placa = document.getElementById("placa"+index).value;
	let desc_articulo = document.getElementById("desc_articulo"+index).value;
	let codigo_articulo = document.getElementById("codigo_articulo"+index).value.split("-")[2];
	let anio = document.getElementById("anio"+index).value;
	let no_entrega = document.getElementById("no_entrega"+index).value;

	let mensaje = "¿Desea eliminar el artículo "+desc_articulo+", código de artículo #"+codigo_articulo+", entrega número #"+no_entrega;
	let query = "DELETE FROM tbl_con_temp_activo t WHERE t.COMPANIA = "+compania+" AND t.COD_ARTICULO = "+codigo_articulo+" AND t.ANIO = "+anio+" AND t.NO_ENTREGA = "+no_entrega+" AND t.SECUENCIA = "+secuencia;
	if (placa != null && placa != "") {
		query += " AND t.PLACA = "+placa;
		mensaje += " y placa #"+placa+"?";
	} else {
		mensaje += "?";
	}

	if (!confirm(mensaje)) return;

	try {
		let result = await executeDB('<%=request.getContextPath()%>',query,'tbl_con_temp_activo')
		if (result) {
			articulo.remove();
			detalle.remove();
		} else {
			alert("No se pudo completar el procedimiento.")
		}
	} catch (error) {
		alert(error)
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()" >
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - REGISTRO DE ACTIVOS FIJOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

	<table width="100%" cellpadding="0" cellspacing="0">
					<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("mode",mode)%>
	<tr class="TextFilter">
		<td width="15%">No. de Placa</td>
		<td width="85%" colspan="2">
		<%=fb.textBox("placa",placa,false,false,false,10,null,null,null)%>

		&nbsp;&nbsp;Familias&nbsp;<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clases
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');
		</script>
		&nbsp;&nbsp;Codigo <%=fb.textBox("articulo",articulo,false,false,false,15,null,null,null)%>
		</td>
		</tr>
		<tr class="TextFilter">
				<td>Unidad Adm.</td>
				<td colspan="2"><%=fb.intBox("unidad",unidad,false,false,false,10,null,null,"onChange=\"javascript:changeDesc()\"")%><%=fb.textBox("descUnd",descUnd,false,false,true,60)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:showArea()\"")%>

				&nbsp;Desc. Artículo <%=fb.textBox("articuloDesc",articuloDesc,false,false,false,25,null,null,null)%>
				 </td>
					</tr>

		<tr class="TextFilter">
		<td>Rango de Fecha</td>
		<td colspan="2">
		<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaini" />
			<jsp:param name="valueOfTBox1" value="<%=fechaini%>" />
			<jsp:param name="nameOfTBox2" value="fechafin" />
			<jsp:param name="valueOfTBox2" value="<%=fechafin%>" />
			</jsp:include><%=fb.submit("go","Ir")%></td>
			 <%=fb.formEnd()%>
	</tr>


			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
				<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
				<%=fb.hidden("articulo",articulo).replaceAll(" id=\"articulo\"","")%>
				<%=fb.hidden("articuloDesc",articuloDesc)%>
				<%=fb.hidden("unidad",unidad)%>
				<%=fb.hidden("descUnd",descUnd)%>
				<%=fb.hidden("placa",placa)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("familyCode",familyCode)%>
				<%=fb.hidden("classCode",classCode)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("articuloDesc",articuloDesc)%>
				<%=fb.hidden("unidad",unidad)%>
				<%=fb.hidden("descUnd",descUnd)%>
				<%=fb.hidden("placa",placa)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
	<div id="_cMain" class="Container">
		<div id="_cContent" class="ContainerContent">
		 <table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fechaini",fechaini)%>
		<%=fb.hidden("fechafin",fechafin)%>
		<%=fb.hidden("size",""+iActivo.size())%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("activoLastLineNo",""+activoLastLineNo)%>
		<%=fb.hidden("familyCode",familyCode)%>
		<%=fb.hidden("classCode",classCode)%>
		<%=fb.hidden("articulo",articulo)%>
		<%=fb.hidden("articuloDesc",articuloDesc)%>
		<%=fb.hidden("unidad",unidad)%>
		<%=fb.hidden("descUnd",descUnd)%>
		<%=fb.hidden("placa",placa)%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("rCount","0")%>
<%fb.appendJsValidation("\n\tif(document."+fb.getFormName()+".baction.value=='+'||document."+fb.getFormName()+".baction.value=='X') return true;");%>

		<tr class="TextHeader" align="center">
			<td width="3%">No. Placa</td>
			<td width="24%">Desc. Articulo</td>
			<td width="10%">Codigo</td>
			<td width="22%">Unidad Administrativa</td>
			<td width="12%">Fecha Entrada</td>
			<td width="6%">Orden Compra</td>
			<td width="6%">Año</td>
			<td width="6%">Entrega</td>
						<td width="5%">Apl.</td>
						<td width="3%">Sel.</td>
			<td width="3%"align="center">&nbsp;<%=fb.submit("agregar","+",false,(!appendFilter.trim().equals("")&& !mode.trim().equals("view")&&fg.equalsIgnoreCase("RA"))?false:true,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Activo")%></td>
		</tr>
		<!------>

		<%if(iActivo.size()==0 && !appendFilter.trim().equals("")){%>
							<tr>
								<td colspan="11" class="TextRow01" align="center"> NO HAY ACTIVOS REGISTRADOS </td>
							</tr>
							<%}%>
<%
al = CmnMgr.reverseRecords(iActivo);
for (int i=1; i<=iActivo.size(); i++)
{
	 key = al.get(i-1).toString();
		 ActivosFijos  act = (ActivosFijos) iActivo.get(key);

	String displayActivo = "";

	if (act.getStatus() != null &&  !act.getStatus().trim().equals("") && act.getStatus().equalsIgnoreCase("D")) displayActivo = " style=\"display:none\"";
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("secuencia"+i,act.getSecuencia())%>
		<% if(!fg.trim().equals("RAC")){%>
		<%=fb.hidden("cuentah_activo"+i,act.getCuentahActivo())%>
		<%=fb.hidden("cuentah_espec"+i,act.getCuentahEspec())%>
		<%=fb.hidden("cuentah_detalle"+i,act.getCuentahDetalle())%>
		<%=fb.hidden("tipo_de_depre"+i,act.getTipoDeDepre())%>
		<%=fb.hidden("tipo_activo"+i,act.getTipoActivo())%>
		<%=fb.hidden("valor_inicial"+i,act.getValorInicial())%>
		<%=fb.hidden("cond_fisica"+i,act.getCondFisica())%>
		<%=fb.hidden("npoliza"+i,act.getNpoliza())%>

<% } %>
		<%=fb.hidden("valor_deprem"+i,act.getValorDeprem())%>
		<%=fb.hidden("estatus"+i,act.getEstatus())%>

		<%=fb.hidden("valor_rescate"+i,act.getValorRescate())%>
		<%=fb.hidden("valor_actual"+i,act.getValorActual())%>
		<%=fb.hidden("nivel_codigo_ubic"+i,act.getNivelCodigoUbic())%>
		<%=fb.hidden("acum_deprec"+i,act.getAcumDeprec())%>
		<%=fb.hidden("valor__mejor_acum"+i,act.getValorMejorAcum())%>
		<%=fb.hidden("valor_mejora_actual"+i,act.getValorMejoraActual())%>
		<%=fb.hidden("valor_depre_mejora"+i,act.getValorDepreMejora())%>
		<%=fb.hidden("acum_deprem"+i,act.getAcumDeprem())%>
		<%=fb.hidden("meses_depre_act"+i,act.getMesesDepreAct())%>
		<%=fb.hidden("observacion"+i,act.getObservacion())%>

		<%=fb.hidden("usua_crea"+i,act.getUsuaCrea())%>
		<%=fb.hidden("fecha_crea"+i,act.getFechaCrea())%>
		<%=fb.hidden("cod_clasif"+i,act.getCodClasif())%>

		<%=fb.hidden("estado"+i,act.getEstado())%>
			<%=fb.hidden("usuario_crea_activo"+i,act.getUsuarioCreaActivo())%>
		<%=fb.hidden("fecha_crea_activo"+i,act.getFechaCreaActivo())%>
		<%=fb.hidden("usuario_anula_activo"+i,act.getUsuarioAnulaActivo())%>
		<%=fb.hidden("fecha_anula_activo"+i,act.getFechaAnulaActivo())%>
		<%=fb.hidden("secuencia_placa"+i,act.getSecuenciaPlaca())%>
		<%=fb.hidden("ue_codigo"+i,act.getUeCodigo())%>
		<%=fb.hidden("cod_flia"+i,act.getCodFlia())%>
		<%=fb.hidden("cod_clase"+i,act.getCodClase())%>
		<%=fb.hidden("cod_articulo"+i,act.getCodArticulo())%>
		<%=fb.hidden("cargo_uso"+i,"N")%>
				<%=fb.hidden("status"+i,act.getStatus())%>
				<%=fb.hidden("placaNueva"+i,act.getPlacaNueva())%>
				<%=fb.hidden("placaOld"+i,act.getPlaca())%>

		<tr id="articulo<%=i%>" class="<%=color%>" <%=displayActivo%>>
			<td align="center"><%=fb.textBox("placa"+i,act.getPlacaNew(),false,false,viewMode,10,20,"Text10",null,null)%></td>
			<td align="center"><%=fb.textBox("desc_articulo"+i,act.getDescArticulo(),false,false,true,35,"Text10",null,null)%></td>
			<td align="center"><%=fb.textBox("codigo_articulo"+i,act.getCodigoArticulo(),false,false,true,5,"Text10",null,null)%>
			<%=fb.button("buscarArt"+i,"...",false,(act.getSecuencia() != null && !act.getSecuencia().trim().equals("0")|| viewMode )?true:false,"","","onClick=\"javascript:buscaArt('"+i+"')\"")%></td>
			<td align="center"><%//=fb.textBox("ue_codigo"+i,cdo.getColValue("ue_codigo"),false,false,true,2,"Text10",null,null)%>
			<%=fb.textBox("desc_unidad"+i,act.getDescUnidad(),false,false,true,30,"Text10",null,null)%>
			<%=fb.button("buscarUnd"+i,"...",false,(viewMode || !fg.equalsIgnoreCase("RA")),"","","onClick=\"javascript:buscaUnd('"+i+"')\"")%></td>
			<td align="center"><%//=fb.textBox("fecha_entrada"+i,cdo.getColValue("fecha_entrada"),false,false,false,10,"Text10",null,null)%>

				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="<%="fecha_entrada"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=(act.getFechaDeEntrada() != null)?act.getFechaDeEntrada():""%>" />
								<jsp:param name="readonly" value="<%=(viewMode && !fg.equalsIgnoreCase("RA"))?"y":"n"%>"/>
				</jsp:include>
			</td>
			<td align="center"><%=fb.textBox("orden__compra"+i,act.getOrdenCompra(),false,false,viewMode,10,"Text10",null,null)%></td>
			<td align="center"><%=fb.intBox("anio"+i,act.getAnio(),false,false,viewMode,5,4,"Text10",null,null)%></td>
			<td align="center"><%=fb.textBox("no_entrega"+i,act.getNoEntrega(),false,false,viewMode,5,"Text10",null,null)%></td>

						<td><%=fb.checkbox("check"+i,"R",false,viewMode,null,null,"")%>
			 <img src="../images/dwn.gif" onClick="javascript:displayDet(<%=i%>,'CH')" style="cursor:pointer"></td>
			<td align="center"><%=fb.checkbox("checkActivo"+i,"S",false,viewMode,null,null,"onClick=\"javascript:validaFecha("+i+")\"")%></td>
						<td align="center"><%=fb.button("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+act.getSecuencia()+"',"+i+")\"","Eliminar")%></td>
		</tr>

	<%if(fg.trim().equals("RAC")){%>

	<tr class="TextHeader02" align="center" id="detalle<%=i%>" style="display:none">
	<td colspan="11">
	<table align="center" width="100%" cellpadding="0" cellspacing="1" class="<%=color%>">
	<tr class="TextHeader02" align="center">
			<td width="35%">Cuenta de Activo</td>
			<td width="25%">Detalle</td>
			<td width="20%">Tipo de Entrada</td>
			<td width="20%">Metodo de Depereciación</td>
	</tr>

	<tr class="<%=color%>">
			 <td align="center"><%=fb.textBox("cuentah_activo"+i,act.getCuentahActivo(),false,false,true,4,"Text10",null,null)%>
				<%=fb.textBox("cuentah_espec"+i,act.getCuentahEspec(),false,false,true,4,"Text10",null,null)%>
				<%=fb.textBox("cuenta_desc"+i,act.getCuentaDesc(),false,false,true,38,"Text10",null,null)%>
				<%=fb.button("buscarCta"+i,"...",false,viewMode,"","","onClick=\"javascript:buscaCta('"+i+"')\"")%></td>
			<td align="center">

						<%//=fb.select("cuentah_detalle"+i,"","",false,false,0,null,null,"")%>
						<%=fb.textBox("cuentah_detalle"+i,act.getCuentahDetalle(),false,false,true,4,"Text10",null,null)%>
				<%=fb.textBox("desc_detalle"+i,act.getDescDetalle(),false,false,true,30,"Text10",null,null)%>
				<%=fb.button("buscarDetalle"+i,"...",false,viewMode,"","","onClick=\"javascript:buscaCtaDetalle('"+i+"')\"")%>


			<td align="center"><%=fb.select("entrada_codigo_con"+i,alTipo,act.getEntradaCodigo(),false,false,0,"Text10",null,null,null,"S")%>
							<%//=fb.select("entrada_codigo"+i,al2,"")%>



						</td>
			<td align="center"><%=fb.select("tipo_de_depre"+i,"LINEAR=LINEA RECTA,SUMDIG=SUMA DE DIGITOS,VALORDEC=VALOR DECRECIENTE",act.getTipoDeDepre(),false,false,0,"Text10",null,null,null,"")%></td>
		</tr>
		</table>
		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="<%=color%>">
		<tr class="TextHeader02" align="center">
			<td width="10%">Tipo Activo</td>
			<td width="08%">Valor Inicial</td>
			<td width="07%">Vida Estimada</td>
			<td width="10%">No. Factura</td>
			<td width="25%">Proveedor</td>
			<td width="10%">Cond. Física</td>
			<td width="15%">Fecha Fin Garantia</td>
			<td width="08%">No. Poliza</td>
			<td width="07%">No. Serie</td>
		</tr>
		<tr class="<%=color%>">
			<td align="center"><%=fb.select("tipo_activo"+i,"I=INMUEBLE,B=BIEN,T=TERRENO",act.getTipoActivo(),false,false,0,"Text10",null,null,null,"")%></td>
		 <td align="center"><%=fb.decBox("valor_inicial"+i,act.getValorInicial(),false,false,false,7,"Text10",null,null)%></td>
			<td align="center"><%=fb.intBox("vida_estimada"+i,act.getVidaEstimada(),false,false,viewMode,4,3,"Text10",null,null)%></td>
			<td align="center"><%=fb.textBox("factura"+i,act.getFactura(),false,false,true,10,22,"Text10",null,null)%></td>
		 <td align="center"><%=fb.textBox("cod_provee"+i,act.getCodProvee(),false,false,true,4,"Text10",null,null)%>
					<%=fb.textBox("desc_proveedor_con"+i,act.getDescProveedor(),false,false,true,30,"Text10",null,null)%> </td>
			<td align="center"><%=fb.select("cond_fisica"+i,"BUE=BUENO,NUE=NUEVO,REG=REGULAR,SEG=SEGUNDA",act.getCondFisica(),false,false,0,"Text10",null,null,null,"")%></td>
		<td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="<%="final_garantia"+i%>"/>
											<jsp:param name="valueOfTBox1" value="<%=(act.getFinalGarantia() != null)?act.getFinalGarantia():""%>" />
											</jsp:include>
			</td>
			 <td align="center"><%=fb.textBox("npoliza"+i,act.getNpoliza(),false,false,viewMode,7,20,"Text10",null,null)%></td>
				<td align="center"><%=fb.textBox("numero_serie"+i,act.getNumeroSerie(),false,false,true,7,100,"Text10",null,null)%></td>

		 </tr>
		<tr class="<%=color%>">
			<td colspan="11">Observaci&oacute;n<%=fb.textarea("comentario"+i,act.getComentario(),false,false,viewMode,60,1,2000,"","width:100%","")%></td>
		</tr>
		<tr class="<%=color%>">
			<td colspan="11">&nbsp;</td>
		</tr>
		</table>

		</td>
		</tr>

		<% } else { %>

	<tr class="TextHeader02" align="center" id="detalle<%=i%>" style="display:none">
	<td colspan="11">
	<table align="center" width="100%" cellpadding="0" cellspacing="1" class="<%=color%>">
	<tr class="TextHeader02" align="center">
			<td width="10%">No. Factura</td>
			<td width="40%">Proveedor</td>
			<td width="10%">Vida Estimada</td>
			<td width="15%">Fecha Fin Garantia</td>
			<td width="10%">No Serie</td>
			<td width="15%">Tipo Entrada</td>
		</tr>

		<tr class="<%=color%>">
			<td align="center"><%=fb.textBox("factura"+i,act.getFactura(),false,false,viewMode,10,22,"Text10",null,null)%></td>
			<td align="center"><%=fb.textBox("cod_provee"+i,act.getCodProvee(),false,false,true,4,"Text10",null,null)%>
				<%=fb.textBox("desc_proveedor"+i,act.getDescProveedor(),false,false,true,35,"Text10",null,null)%>
				<%=fb.button("buscarProv"+i,"...",false,viewMode,"","","onClick=\"javascript:buscaProv('"+i+"')\"")%></td>
			<td align="center"><%=fb.intBox("vida_estimada"+i,act.getVidaEstimada(),false,false,viewMode,4,3,"Text10",null,null)%></td>
			<td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="<%="final_garantia"+i%>"/>
											<jsp:param name="valueOfTBox1" value="<%=(act.getFinalGarantia() != null)?act.getFinalGarantia():""%>" />
											</jsp:include>
			</td>
			<td align="center"><%=fb.textBox("numero_serie"+i,act.getNumeroSerie(),false,false,viewMode,10,100,"Text10",null,null)%></td>
			<td align="center"><%=fb.select("entrada_codigo"+i,alTipo,cdo.getColValue("entrada_codigo"),"")%></td>
		</tr>
		<tr class="<%=color%>">
			<td colspan="6">Observaci&oacute;n<%=fb.textarea("comentario"+i,act.getComentario(),false,false,viewMode,60,2,2000,"","width:100%","")%></td>
		</tr>
		</table>

		</td>
		</tr>
			<%}%>
<%
}
%>
<%if(iActivo.size() !=0 && !mode.trim().equals("view")){%>
<tr class="TextHeader">
<td colspan="11"> Valores a Aplicar sobre los Artículos Seleccionados </td>
</tr>
<%if(!fg.trim().equals("RAC")){%>
<tr class="TextRow01">
		<td colspan="11">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow01" align="center">
								<td>No. Orden de Compra</td>
								<td>No. de Factura</td>
								<td align="center">Proveedor</td>
								<td>Vida Estimada</td>
								<td>Final de Garantia</td>
								<td>&nbsp;</td>
						</tr>
<tr class="TextRow01" align="center">
<td><%=fb.textBox("orden00","",false,false,viewMode,10,"Text10",null,null)%></td>
<td><%=fb.textBox("factura00","",false,false,viewMode,10,"Text10",null,null)%></td>
<td><%=fb.textBox("cod_provee00","",false,false,viewMode,10,"Text10",null,null)%>
<%=fb.textBox("desc_proveedor00","",false,true,viewMode,30,"Text10",null,null)%>
<%=fb.button("buscarProv00","...",false,viewMode,"","","onClick=\"javascript:buscaProv('00')\"")%> </td>
<td><%=fb.intBox("vida_estimada00","",false,false,viewMode,10,3,"Text10",null,null)%></td>
<td>	<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="final_garantia00"/>
		<jsp:param name="valueOfTBox1" value="" />
		</jsp:include></td>

<td align="left"><%=fb.button("apl","Aplicar",false,viewMode,"","","onClick=\"javascript:aplicarVal()\"")%> </td>
</tr>
</table>
</td></tr>
<%}else {%>
<tr class="TextRow01">
		<td colspan="11">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<tr class="TextRow01" align="center">
<td width="40%">Cuenta de Activo:&nbsp;<%=fb.textBox("cuentah_activo00","",false,false,true,4,"Text10",null,null)%>
	<%=fb.textBox("cuentah_espec00","",false,true,true,4,"Text10",null,null)%>
		<%=fb.textBox("cuenta_desc00","",false,true,true,20,"Text10",null,null)%>
	<%=fb.button("buscarCta00","...",false,viewMode,"","","onClick=\"javascript:buscaCta('00')\"")%> </td>

<td width="25%">Detalle:&nbsp;<%=fb.textBox("cuentah_detalle00","",false,false,true,4,"Text10",null,null)%>
	<%=fb.textBox("desc_detalle00","",false,true,true,20,"Text10",null,null)%>
		<%=fb.button("buscarCta00","...",false,viewMode,"","","onClick=\"javascript:buscaCtaDetalle('00')\"")%> </td>

<td width="15%">Vida Estimada:&nbsp;<%=fb.intBox("vida_estimada00","",false,false,viewMode,5,3,"Text10",null,null)%></td>
<td width="20%" align="left"><%=fb.button("aplica","Aplicar",false,viewMode,"","","onClick=\"javascript:aplicarValCon()\"")%> </td>
</tr>
</table>
</td></tr>

<%fb.appendJsValidation("if(error>0)doAction();");
//fb.appendJsValidation("if(!cargarActivos())error++;");
}%>

<tr class="TextRow02">
	 <td colspan="11" align="right">&nbsp;<%if(fg.trim().equals("RAC")){%>
		<%=fb.button("savecrea","Crear Activo",true,viewMode,null,null,"onClick=\"javascript:doEnviar('"+fb.getFormName()+"',this.value)\"")%><%}%>
		<%=fb.button("saveprueba","Guardar",true,viewMode,null,null,"onClick=\"javascript:doEnviar('"+fb.getFormName()+"',this.value)\"")%>
		</td>
	</tr>
	<%}%>
<%=fb.formEnd(true)%>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</table>
		</div>
	</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("familyCode",familyCode)%>
				<%=fb.hidden("classCode",classCode)%>
				<%=fb.hidden("unidad",unidad)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("articuloDesc",articuloDesc)%>
				<%=fb.hidden("descUnd",descUnd)%>
				<%=fb.hidden("placa",placa)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("familyCode",familyCode)%>
				<%=fb.hidden("classCode",classCode)%>
				<%=fb.hidden("articulo",articulo)%>
				<%=fb.hidden("articuloDesc",articuloDesc)%>
				<%=fb.hidden("unidad",unidad)%>
				<%=fb.hidden("descUnd",descUnd)%>
				<%=fb.hidden("placa",placa)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%}
//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post

	ArrayList al1= new ArrayList();
	String baction = request.getParameter("baction");
	String itemRemoved = "",pWhere="";
	int size = 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

	al1.clear();
	Activos activo = new Activos();
	activo.setCompania((String) session.getAttribute("_companyId"));
	activo.setFg(fg);
	if(fg.trim().equals("RAC") && baction.equalsIgnoreCase("Crear Activo"))activo.setTable("tbl_con_activos");
	else activo.setTable("tbl_con_temp_activo");

activo.getDetalleActivos().clear();

 for(int z=1;z<=size;z++)
 {
			//cdo = new CommonDataObject();
			ActivosFijos  act = new ActivosFijos();

			//cdo.setTableName("tbl_con_temp_activo");
			//cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and estado = 'P' "+pWhere);
			act.setCompania((String) session.getAttribute("_companyId"));
			act.setSecuencia(request.getParameter("secuencia"+z));
			act.setUeCodigo(request.getParameter("ue_codigo"+z));
			act.setCuentahActivo(request.getParameter("cuentah_activo"+z));
			act.setCuentahEspec(request.getParameter("cuentah_espec"+z));
			act.setCuentahDetalle(request.getParameter("cuentah_detalle"+z));

			act.setDescDetalle(request.getParameter("descDetalle"+z));
			act.setFechaDeEntrada(request.getParameter("fecha_entrada"+z));
			act.setEstatus(request.getParameter("estatus"+z));
			act.setTipoActivo(request.getParameter("tipo_activo"+z));
			act.setTipoDeDepre(request.getParameter("tipo_de_depre"+z));
			act.setValorDeprem(request.getParameter("valor_deprem"+z));
			act.setValorInicial(request.getParameter("valor_inicial"+z));
			act.setEntradaCodigo(request.getParameter("entrada_codigo"+z));
			if(fg.trim().equals("RAC"))act.setEntradaCodigo(request.getParameter("entrada_codigo_con"+z));
			act.setFactura(request.getParameter("factura"+z));
			act.setCodProvee(request.getParameter("cod_provee"+z));
			act.setVidaEstimada(request.getParameter("vida_estimada"+z));
			act.setFinalGarantia(request.getParameter("final_garantia"+z));
			act.setNumeroSerie(request.getParameter("numero_serie"+z));
			act.setComentario(request.getParameter("comentario"+z));
			act.setPlacaNew(request.getParameter("placa"+z));

			act.setValorActual(request.getParameter("valor_actual"+z));
			act.setNivelCodigoUbic(request.getParameter("nivel_codigo_ubic"+z));
			act.setOrdenCompra(request.getParameter("orden__compra"+z));

			act.setAcumDeprec(request.getParameter("acum_deprec"+z));
			act.setValorMejorAcum(request.getParameter("valor__mejor_acum"+z));

			act.setValorMejoraActual(request.getParameter("valor_mejora_actual"+z));
			act.setValorDepreMejora(request.getParameter("valor_depre_mejora"+z));
			act.setDescUnidad(request.getParameter("desc_unidad"+z));
			act.setDescArticulo(request.getParameter("desc_articulo"+z));

			if(request.getParameter("desc_proveedor"+z) != null && !request.getParameter("desc_proveedor"+z).trim().equals(""))
				act.setDescProveedor(request.getParameter("desc_proveedor"+z));

				act.setAcumDeprem(request.getParameter("acum_deprem"+z));
				act.setMesesDepreAct(request.getParameter("meses_depre_act"+z));
				act.setObservacion(request.getParameter("observacion"+z));
				act.setCondFisica(request.getParameter("cond_fisica"+z));
				act.setCodClasif(request.getParameter("cod_clasif"+z));
				act.setNpoliza(request.getParameter("npoliza"+z));
				act.setAnio(request.getParameter("anio"+z));

				act.setUsuaMod((String) session.getAttribute("_userName"));
				act.setFechaMod(cDateTime);
				act.setPlaca(request.getParameter("placaOld"+z));
				if(fg.trim().equals("RAC") && baction.equalsIgnoreCase("Crear Activo"))
				{
					act.setUsuaCrea((String) session.getAttribute("_userName"));
					act.setFechaCrea(cDateTime);
					act.setFechaCreaActivo(cDateTime);
					act.setUsuarioCreaActivo((String) session.getAttribute("_userName"));
					if(request.getParameter("valor_rescate"+z) != null && !request.getParameter("valor_rescate"+z).trim().equals(""))
					act.setValorRescate(request.getParameter("valor_rescate"+z));
					else act.setValorRescate("1");
					act.setCargoUso(request.getParameter("cargo_uso"+z));
				}
				else
				{
					act.setUsuaCrea(request.getParameter("usua_crea"+z));
					act.setFechaCrea(request.getParameter("fecha_crea"+z));
					act.setFechaCreaActivo(request.getParameter("fecha_crea_activo"+z));
					act.setUsuarioCreaActivo(request.getParameter("usuario_crea_activo"+z));
					if(request.getParameter("valor_rescate"+z) != null && !request.getParameter("valor_rescate"+z).trim().equals(""))
					act.setValorRescate(request.getParameter("valor_rescate"+z));

					act.setPlaca(request.getParameter("placa"+z));
				}

			act.setNoEntrega(request.getParameter("no_entrega"+z));
			act.setSecuenciaPlaca(request.getParameter("secuencia_placa"+z));
			act.setCodArticulo(request.getParameter("cod_articulo"+z));
			act.setCodClase(request.getParameter("cod_clase"+z));
			act.setCodFlia(request.getParameter("cod_flia"+z));


			act.setPlacaNueva(request.getParameter("placaNueva"+z));
			act.setEstado(request.getParameter("estado"+z));
			act.setCodigoArticulo(request.getParameter("codigo_articulo"+z));
			act.setKey(request.getParameter("key"+z));

			act.setStatus(request.getParameter("status"+z));
			key = request.getParameter("key"+z);

			act.setUsuarioAnulaActivo(request.getParameter("usuario_anula_activo"+z));
			act.setFechaAnulaActivo(request.getParameter("fecha_anula_activo"+z));


		if (request.getParameter("remove"+z) != null && !request.getParameter("remove"+z).equals(""))
		{	act.setStatus("D");
			itemRemoved = act.getKey(); }
		/*else
		{*/
			try
			{

				if ( fg.trim().equals("RAC") && baction.equalsIgnoreCase("Crear Activo"))
				{
					if(request.getParameter("checkActivo"+z) != null)
					{
						act.setSecuencia("0");
						act.setSecuenciaTemp(request.getParameter("secuencia"+z));
						act.setPorcentaje("0");
						int vidaEstimada =0;
						if(request.getParameter("vida_estimada"+z) != null && !request.getParameter("vida_estimada"+z).trim().equals("") )			vidaEstimada = Integer.parseInt(request.getParameter("vida_estimada"+z));
						if(vidaEstimada >0 )
						{
							al1.add(act);
							iActivo.put(key,act);
							activo.addDetalleActivos(act);
						}
					}
				}else
				{
					if ( fg.trim().equals("RAC"))
					{
						if(request.getParameter("checkActivo"+z) != null)
						{
							al1.add(act);
							iActivo.put(key,act);
							activo.addDetalleActivos(act);
						}
					} else
					{
							al1.add(act);
							iActivo.put(key,act);
							activo.addDetalleActivos(act);
					}
				}

			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		//}//End else
	}//end for

	if (!itemRemoved.equals(""))
	{
		//iActivo.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+request.getParameter("fg")+"&change=1&activoLastLineNo="+activoLastLineNo+"&fechaini="+request.getParameter("fechaini")+"&fechafin="+request.getParameter("fechafin")+"&familyCode="+request.getParameter("familyCode")+"&classCode="+request.getParameter("classCode")+"&articulo="+request.getParameter("articulo")+"&unidad="+request.getParameter("unidad")+"&descUnd="+request.getParameter("descUnd"));
		return;
	}
	if (baction.equals("+"))//Agregar
	{
		//cdo = new CommonDataObject();
		ActivosFijos  act = new ActivosFijos();
		act.setSecuencia("0");
		act.setFechaCrea(cDateTime);
		act.setUsuaCrea((String) session.getAttribute("_userName"));
		act.setEstatus("ACTI");
		act.setEstado("P");
		act.setStatus("N");//nuevo Registro

		activoLastLineNo++;
		if (activoLastLineNo < 10) key = "00" + activoLastLineNo;
		else if (activoLastLineNo < 100) key = "0" + activoLastLineNo;
		else key = "" + activoLastLineNo;
		act.setKey(key);
		try
		{
			iActivo.put(key, act);
			activo.addDetalleActivos(act);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+request.getParameter("fg")+"&change=1&activoLastLineNo="+activoLastLineNo+"&fechaini="+request.getParameter("fechaini")+"&fechafin="+request.getParameter("fechafin")+"&familyCode="+request.getParameter("familyCode")+"&classCode="+request.getParameter("classCode")+"&articulo="+request.getParameter("articulo")+"&unidad="+request.getParameter("unidad")+"&descUnd="+request.getParameter("descUnd"));
		return;
	}

	if (baction.equalsIgnoreCase("Guardar")||baction.equalsIgnoreCase("Crear Activo"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(fg.trim().equals("RAC")&& baction.equalsIgnoreCase("Crear Activo"))
		ACTMgr.addActivos(activo);
		else ACTMgr.addActivosTemp(activo);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ACTMgr.getErrCode().equals("1")){
%>
	alert('<%=ACTMgr.getErrMsg()%>');
<%if (session.getAttribute("_urlinfo") != null && ((Hashtable) session.getAttribute("_urlinfo")).containsKey(request.getContextPath()+"/inventario/list_reg_activo_fijo.jsp")) {
%>
	//window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlinfo")).get(request.getContextPath()+"/inventario/list_reg_activo_fijo.jsp")%>';
	window.reload(true);
<%
	} else {
%>
 window.location = '<%=request.getContextPath()%>/inventario/list_reg_activo_fijo.jsp?fg=<%=fg%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&familyCode=<%=familyCode%>&classCode=<%=classCode%>&articulo=<%=articulo%>&unidad=<%=unidad%>&descUnd=<%=descUnd%>';
<%
	}
%>
// window.close();
<%
} else throw new Exception(ACTMgr.getErrMsg());
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
