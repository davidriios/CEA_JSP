<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="IXml" scope="page" class="issi.admin.XMLCreator"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCol" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iIns" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vIns" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iUso" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUso" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iPers" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vPers" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iHon" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vHon" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iNP" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vNP" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iMotSp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMotSp" scope="session" class="java.util.Vector" />
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
IXml.setConnection(ConMgr);

CommonDataObject proc = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
int colLastLineNo = 0;
int insLastLineNo = 0;
int usoLastLineNo = 0;
int persLastLineNo = 0;
int honLastLineNo = 0;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("colLastLineNo") != null) colLastLineNo = Integer.parseInt(request.getParameter("colLastLineNo"));
if (request.getParameter("insLastLineNo") != null) insLastLineNo = Integer.parseInt(request.getParameter("insLastLineNo"));
if (request.getParameter("usoLastLineNo") != null) usoLastLineNo = Integer.parseInt(request.getParameter("usoLastLineNo"));
if (request.getParameter("persLastLineNo") != null) persLastLineNo = Integer.parseInt(request.getParameter("persLastLineNo"));
if (request.getParameter("honLastLineNo") != null) honLastLineNo = Integer.parseInt(request.getParameter("honLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "";

		iCol.clear();
		iIns.clear();
		vIns.clear();
		iUso.clear();
		vUso.clear();
		iPers.clear();
		vPers.clear();
		iHon.clear();
		vHon.clear();
		iNP.clear();
		vNP.clear();		
		iMotSp.clear();
		vMotSp.clear();
		proc.addColValue("codigo","");
	}
	else
	{
		if (id == null) throw new Exception("El Procedimiento no es válido. Por favor intente nuevamente!");

		sql = "select a.codigo, a.estado, a.tipo_categoria, a.observacion, a.descripcion, decode(a.precio,null,' ',a.precio) as precio, decode(a.costo_ref,null,' ',a.costo_ref) as costo_ref,decode(a.costo,null,' ',a.costo) as costo, decode(a.precio_oferta,null,' ',a.precio_oferta) as precio_oferta, decode(a.precio2,null,' ',a.precio2) as precio2, decode(a.costo2,null,' ',a.costo2) as costo2, decode(a.precio_oferta2,null,' ',a.precio_oferta2) as precio_oferta2, decode(a.precio3,null,' ',a.precio3) as precio3, decode(a.costo3,null,' ',a.costo3) as costo3, decode(a.precio_oferta3,null,' ',a.precio_oferta3) as precio_oferta3, decode(a.precio4,null,' ',a.precio4) as precio4, decode(a.costo4,null,' ',a.costo4) as costo4, decode(a.precio_oferta4,null,' ',a.precio_oferta4) as precio_oferta4, decode(a.precio5,null,' ',a.precio5) as precio5, decode(a.costo5,null,' ',a.costo5) as costo5, decode(a.precio_oferta5,null,' ',a.precio_oferta5) as precio_oferta5, a.tiempo_estimado, a.unidad_tiempo, a.cod_cds, a.cod_cds2, a.cod_cds3, a.cod_cds4, a.cod_cds5, (select nombre from tbl_cds_tipo_categoria where codigo=a.tipo_categoria) as tipo_categoria_desc, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds) as desc_cds, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds2) as desc_cds2, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds3) as desc_cds3, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds4) as desc_cds4, (select descripcion from tbl_cds_centro_servicio where codigo=a.cod_cds5) as desc_cds5, tipo_maletin_anestesia, a.nombre_corto from tbl_cds_procedimiento a where a.codigo = '"+id+"'" ;


		proc = SQLMgr.getData(sql);


		if (change == null)
		{
			iCol.clear();
			iIns.clear();
			vIns.clear();
			iUso.clear();
			vUso.clear();
			iPers.clear();
			vPers.clear();
			iHon.clear();
			vHon.clear();
			iNP.clear();
			vNP.clear();

			sql = "SELECT a.art_familia, a.art_clase, a.articulo, b.descripcion, a.cantidad, a.art_familia||'-'||a.art_clase||'-'||a.articulo as code, a.paquete, to_char( nvl(b.precio_venta,0), '9,999999.99' ) precio_venta, (select to_char(nvl(precio,0), '9,999999.99') from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario  where compania = b.compania and cod_articulo = b.cod_articulo) and compania = b.compania and cod_articulo = b.cod_articulo ) costo FROM tbl_cds_insumo_x_proc a, tbl_inv_articulo b WHERE a.articulo=b.cod_articulo and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_proced='"+id+"'  order by b.descripcion";

			al  = SQLMgr.getDataList(sql);

			insLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iIns.put(key, cdo);
					vIns.addElement(cdo.getColValue("code"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
						 
			sql = "SELECT cod_uso, (select descripcion from tbl_sal_uso where codigo=cod_uso and compania=cod_compania) as observacion,nvl(cantidad,0)cantidad,tipo_uso, (select to_char(nvl(precio_venta,0), '9,999999.99' ) precio_venta from tbl_sal_uso where codigo=cod_uso and compania=cod_compania) precio_venta, (select to_char(nvl(costo,0), '9,999999.99' ) costo from tbl_sal_uso where codigo=cod_uso and compania=cod_compania) costo FROM tbl_cds_activo_x_proc WHERE cod_compania="+(String) session.getAttribute("_companyId")+" and procedimiento='"+id+"' order by 2";
			al  = SQLMgr.getDataList(sql);

			usoLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iUso.put(key, cdo);
					vUso.addElement(cdo.getColValue("cod_uso"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sql = "SELECT a.cod_funcion, b.descripcion, a.cantidad FROM tbl_cds_personal_x_proc a, tbl_cds_funcion b WHERE a.cod_funcion=b.codigo and cod_procedimiento='"+id+"' order by b.descripcion";
			al  = SQLMgr.getDataList(sql);

			persLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iPers.put(key, cdo);
					vPers.addElement(cdo.getColValue("cod_funcion"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sql = "SELECT a.cod_tipo_honorario, b.descripcion, a.precio, a.costo FROM tbl_cds_honorario_x_proc a, tbl_cds_tipo_honorario b WHERE a.cod_tipo_honorario=b.codigo and cod_procedimiento='"+id+"' order by b.descripcion";
			al  = SQLMgr.getDataList(sql);

			honLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iHon.put(key, cdo);
					vHon.addElement(cdo.getColValue("cod_tipo_honorario"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			sql = "select nivel, nivel_nombre, compania, ref_type, ref_table, ref_code, cargo_servicio, cargo_code, precio, precio_oferta, to_char(fecha_ini_oferta, 'dd/mm/yyyy') fecha_ini_oferta, to_char(fecha_fin_oferta, 'dd/mm/yyyy') fecha_fin_oferta, oferta_aplica_emp, usuario_creacion, usuario_modificacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, other1, other2, other3 from tbl_fac_nivel_precio where compania = "+(String) session.getAttribute("_companyId")+" and cargo_servicio = 7 and cargo_code = '"+id+"'";
			al  = SQLMgr.getDataList(sql);

			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				if (i < 10) key = "00" + (i+1);
				else if (i < 100) key = "0" + (i+1);
				else key = "" + (i+1);

				try
				{
					iNP.put(key, cdo);
					vNP.addElement(cdo.getColValue("ref_type")+"-"+cdo.getColValue("ref_code")+"-"+cdo.getColValue("cargo_servicio")+"-"+cdo.getColValue("cargo_code"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Procedimiento -  Edición - '+document.title;
function checkCode(obj)
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cds_procedimiento','codigo=\''+obj.value+'\'','<%=proc.getColValue("codigo")%>'));
	{
	 //  document.form0.codigo.value = '';
			 return true;
	 } //  else
			// return false;
}


function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
/*
function principalChecked()
{
	if (document.form3.baction.value == 'Guardar' && <%//=iUbi.size()%> != 0)
	{
<%
//for (int i=1; i<=iUbi.size(); i++)
//{
%>
		<%//=(i==1)?"":"else "%>if (document.form3.principal<%//=i%>.checked) return true;
<%
//}
%>
		return false;
	}
	else return true;
}
*/

function selMaletin()
{
	 abrir_ventana1('../common/search_maletin.jsp');
}

function addCateg()
{
	 abrir_ventana1('../common/search_tipocategoria.jsp');
}

function addCentro(k)
{
	 abrir_ventana1('../common/search_centro_servicio.jsp?fp=procedimiento&index='+k);
}

function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
		showArticuloList();
<%
		}
		else if (tab.equals("2"))
		{
%>
		showUsoList();
<%
		}
		else if (tab.equals("3"))
		{
%>
		showPersonalList();
<%
		}
		else if (tab.equals("4"))
		{
%>
		showHonorarioList();
<%
		}
	}
%>
}


function showArticuloList()
{
	abrir_ventana1('../common/check_articulo.jsp?fp=procedimiento&mode=<%=mode%>&id=<%=id%>&colLastLineNo=<%=colLastLineNo%>&insLastLineNo=<%=insLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&honLastLineNo=<%=honLastLineNo%>');
}

function showUsoList()
{
	abrir_ventana1('../common/check_uso.jsp?fp=procedimiento&mode=<%=mode%>&id=<%=id%>&colLastLineNo=<%=colLastLineNo%>&insLastLineNo=<%=insLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&honLastLineNo=<%=honLastLineNo%>');
}

function showPersonalList()
{
	abrir_ventana1('../common/check_personal.jsp?fp=procedimiento&mode=<%=mode%>&id=<%=id%>&colLastLineNo=<%=colLastLineNo%>&insLastLineNo=<%=insLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&honLastLineNo=<%=honLastLineNo%>');
}

function showHonorarioList()
{
	abrir_ventana1('../common/check_honorario.jsp?fp=procedimiento&mode=<%=mode%>&id=<%=id%>&colLastLineNo=<%=colLastLineNo%>&insLastLineNo=<%=insLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&honLastLineNo=<%=honLastLineNo%>');
}

function chkRefType(i){
	var nivel = eval('document.form7.nivel'+i).value;
	var ref_type = eval('document.form7.ref_type'+i).value;
	var ref_code = eval('document.form7.ref_code'+i).value;
		if(ref_code=='' && nivel == 0){
			eval('document.form7.ref_type_'+i).value = eval('document.form7.ref_type'+i).value;
			if(ref_type == 1 || ref_type == 2){
				eval('document.form7.ref_code'+i).value='';
				document.getElementById('ECS'+i).style.display = '';
				document.getElementById('TCA'+i).style.display = 'none';
			} else {
				eval('document.form7.ref_code'+i).value='-';
				document.getElementById('ECS'+i).style.display = 'none';
				document.getElementById('TCA'+i).style.display = '';
			}
		} else {
			eval('document.form7.ref_type'+i).value = eval('document.form7.ref_type_'+i).value;
		}
}

function showRef(i)
{
	var ref_type = eval('document.form7.ref_type'+i).value;
	if(ref_type==1){
		abrir_ventana1('../common/search_empresa.jsp?fp=procedimientos&index='+i);
	} else if(ref_type==2){
		abrir_ventana1('../common/search_centro_servicio.jsp?fp=procedimientos&index='+i);
	} else if(ref_type==3){
		abrir_ventana1('../common/check_honorario.jsp?fp=procedimiento&mode=<%=mode%>&id=<%=id%>');
	}
}

function clearRC(i)
{
	var nivel = eval('document.form7.nivel'+i).value;
	if(nivel=='0'){
		eval('document.form7.ref_code'+i).value = '';
	}
}
function showReporte(opt){
  <%if(mode.equalsIgnoreCase("edit")){%>
	var cpt = '<%=id%>';
	if(cpt != '') {
    if(!opt) abrir_ventana('../inventario/print_cdc_insumos.jsp?cpt='+cpt);
    else if(opt==1) abrir_ventana('../inventario/print_cdc_insumos.jsp?cost=Y&cpt='+cpt);
    else if(opt==2) abrir_ventana('../inventario/print_cdc_insumos.jsp?price=Y&cpt='+cpt);
  }
  <%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISIÓN - MANTENIMIENTO - PROCEDIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
			<%if(mode.equalsIgnoreCase("edit")){%>
		<tr class="TextRow02">
			<td align="right">
          <%//=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
          <button type="button" onclick="javascript:showReporte()" class="CellbyteBtn">Generar Reporte</button>
          <button type="button" onclick="javascript:showReporte(1)" class="CellbyteBtn">Con Costo</button>
          <button type="button" onclick="javascript:showReporte(2)" class="CellbyteBtn">Con Precio</button>
      </td>	
		</tr>	
			<%}%>
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>

				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="1">Generales</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td width="12%"><cellbytelabel id="2">CPT</cellbytelabel></td>
					<td width="38%"><%=fb.textBox("codigo",id,true,false,(mode.equalsIgnoreCase("edit")),30,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>
					<td width="12%"><cellbytelabel id="3">Categor&iacute;a</cellbytelabel></td>
					<td width="38%"><%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_cds_tipo_categoria","tipo_categoria",proc.getColValue("tipo_categoria"),false,false,0,null,null,null,null,"S")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Estado</cellbytelabel></td>
					<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",proc.getColValue("estado"),false,false,0,"Text10",null,null,null,"")%></td>
					<td><cellbytelabel id="5">Tiempo estimado</cellbytelabel></td>
					<td>
						<%=fb.intBox("tiempo_estimado",proc.getColValue("tiempo_estimado"),false,false,false,5)%><cellbytelabel id="6">Hrs</cellbytelabel>
						<%=fb.intBox("unidad_tiempo",proc.getColValue("unidad_tiempo"),false,false,false,5)%><cellbytelabel id="7">Min</cellbytelabel>
					</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="8">Nombre</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
						<td><cellbytelabel id="9">Espa&ntilde;o</cellbytelabel>l</td>
					<td colspan="3"><%=fb.textBox("observacion",proc.getColValue("observacion"),false,false,false,127)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="10">Ingl&eacute;s</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("descripcion",proc.getColValue("descripcion"),true,false,false,127)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="16">ELABO</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("nombre_corto",proc.getColValue("nombre_corto"),false,false,false,50)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="11">Niveles de Precios</cellbytelabel></td>
					<!--<td colspan="2">&nbsp;Areas de los Procedimientos</td>-->
				</tr>
				<tr class="TextRow01">
					<td colspan="4">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr align="center" class="TextHeader01">
							<td width="25%">&nbsp;</td>
							<td width="25%"><cellbytelabel id="12">Precio</cellbytelabel></td>
							<!--<td width="25%">Ambulatorio</td>-->
							<td width="25%"><cellbytelabel id="13">Costo Referencia</cellbytelabel></td>
							<td width="25%"><cellbytelabel id="13">Costo a Mayorizar</cellbytelabel></td>
						</tr>
						<tr align="center">
							<td align="left"><cellbytelabel id="14">Precios</cellbytelabel>:</td>
							<td><%=fb.decBox("precio",proc.getColValue("precio"),false,false,false,9,6.2)%></td>
							<%=fb.hidden("precio_oferta","0")%>
							<!--<td>
							<%//=fb.decBox("precio_oferta",proc.getColValue("precio_oferta"),false,false,false,9,6.2)%></td>-->
							<td><%=fb.decBox("costo_ref",proc.getColValue("costo_ref"),false,false,false,9,6.2)%></td>
							<td><%=fb.decBox("costo",proc.getColValue("costo"),false,false,false,9,6.2)%></td>
						</tr>
						<!--
						<tr align="center">
							<td align="left">Nivel 2</td>
							<td><%//=fb.decBox("precio2",proc.getColValue("precio2"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("precio_oferta2",proc.getColValue("precio_oferta2"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("costo2",proc.getColValue("costo2"),false,false,false,9,6.2)%></td>
						</tr>
						<tr align="center">
							<td align="left">Nivel 3</td>
							<td><%//=fb.decBox("precio3",proc.getColValue("precio3"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("precio_oferta3",proc.getColValue("precio_oferta3"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("costo3",proc.getColValue("costo3"),false,false,false,9,6.2)%></td>
						</tr>
						<tr align="center">
							<td align="left">Nivel 4</td>
							<td><%//=fb.decBox("precio4",proc.getColValue("precio4"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("precio_oferta4",proc.getColValue("precio_oferta4"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("costo4",proc.getColValue("costo4"),false,false,false,9,6.2)%></td>
						</tr>
						<tr align="center">
							<td align="left">Nivel 5</td>
							<td><%//=fb.decBox("precio5",proc.getColValue("precio5"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("precio_oferta5",proc.getColValue("precio_oferta5"),false,false,false,9,6.2)%></td>
							<td><%//=fb.decBox("costo5",proc.getColValue("costo5"),false,false,false,9,6.2)%></td>
						</tr>
						-->
						</table>
					</td>
					<!--
					<td colspan="2">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr align="center" class="TextHeader01">
							<td width="5%">Area</td>
							<td width="95%">&nbsp;</td>
						</tr>
						<tr>
							<td>1</td>
							<td>
								<%//=fb.intBox("cod_cds",proc.getColValue("cod_cds"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds,desc_cds')\"")%>
								<%//=fb.textBox("desc_cds",proc.getColValue("desc_cds"),false,false,true,35,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds,desc_cds')\"")%>
								<%//=fb.button("btnCentro","...",true,false,null,null,"onClick=\"javascript:addCentro('')\"")%>
							</td>
						</tr>
						<tr>
							<td>2</td>
							<td>
								<%//=fb.intBox("cod_cds2",proc.getColValue("cod_cds2"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds2,desc_cds2')\"")%>
								<%//=fb.textBox("desc_cds2",proc.getColValue("desc_cds2"),false,false,true,35,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds2,desc_cds2')\"")%>
								<%//=fb.button("btnCentro2","...",true,false,null,null,"onClick=\"javascript:addCentro('2')\"")%>
							</td>
						</tr>
						<tr>
							<td>3</td>
							<td>
								<%//=fb.intBox("cod_cds3",proc.getColValue("cod_cds3"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds3,desc_cds3')\"")%>
								<%//=fb.textBox("desc_cds3",proc.getColValue("desc_cds3"),false,false,true,35,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds3,desc_cds3')\"")%>
								<%//=fb.button("btnCentro3","...",true,false,null,null,"onClick=\"javascript:addCentro('3')\"")%>
							</td>
						</tr>
						<tr>
							<td>4</td>
							<td>
								<%//=fb.intBox("cod_cds4",proc.getColValue("cod_cds4"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds4,desc_cds4')\"")%>
								<%//=fb.textBox("desc_cds4",proc.getColValue("desc_cds4"),false,false,true,35,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds4,desc_cds4')\"")%>
								<%//=fb.button("btnCentro4","...",true,false,null,null,"onClick=\"javascript:addCentro('4')\"")%>
							</td>
						</tr>
						<tr>
							<td>5</td>
							<td>
								<%//=fb.intBox("cod_cds5",proc.getColValue("cod_cds5"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds5,desc_cds5')\"")%>
								<%//=fb.textBox("desc_cds5",proc.getColValue("desc_cds5"),false,false,true,35,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cod_cds5,desc_cds5')\"")%>
								<%//=fb.button("btnCentro5","...",true,false,null,null,"onClick=\"javascript:addCentro('5')\"")%>
							</td>
						</tr>
						</table>
					</td>-->
				</tr>
				<tr class="TextRow01">
					<td colspan="4">
						<jsp:include page="../common/bitacora.jsp" flush="true">
							<jsp:param name="audTable" value="tbl_cds_procedimiento"></jsp:param>
							<jsp:param name="audFilter" value="<%="codigo='"+id+"'"%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel id="16">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>


<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="19">Insumos del Procedimiento</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="20">C&oacute;digo del Insumo</cellbytelabel></td>
							<td width="50%"><cellbytelabel id="21">Descripci&oacute;n</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="22">Cantidad</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="22">Precio</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="22">Costo</cellbytelabel></td>
							<td width="6%"><cellbytelabel id="36">Paquete?</cellbytelabel></td>
							<td width="5%"><%=fb.submit("btnaddIns","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Insumos")%></td>
						</tr>
						<%
						al = CmnMgr.reverseRecords(iIns);
						double totPrecioVenta  = 0, totCosto = 0;
						for (int i=1; i<=iIns.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdo = (CommonDataObject) iIns.get(key);
							
							totPrecioVenta += Double.parseDouble(cdo.getColValue("precio_venta","0"));
							totCosto += Double.parseDouble(cdo.getColValue("costo","0"));

						%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("code"+i,cdo.getColValue("code"))%>
						<%=fb.hidden("familyCode"+i,cdo.getColValue("art_familia"))%>
						<%=fb.hidden("classCode"+i,cdo.getColValue("art_clase"))%>
						<%=fb.hidden("itemCode"+i,cdo.getColValue("articulo"))%>
						<%=fb.hidden("item"+i,cdo.getColValue("descripcion"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("code")%></td>
														<td><%=cdo.getColValue("descripcion")%></td>
							<td align="center"><%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,false,5,4)%></td>
							<td align="center"><b><%=cdo.getColValue("precio_venta")%></b></td>
							<td align="center"><b><%=cdo.getColValue("costo")%></b></td>
							<td align="center"><%=fb.checkbox("paquete"+i,cdo.getColValue("paquete"),(cdo.getColValue("paquete")!=null && cdo.getColValue("paquete").equals("S")?true:false),false)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Insumo")%></td>
						</tr>
						<%
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						<tr class="TextHeader02">
              <td align="right" colspan="3">Total</td>
              <td align="center"><%=CmnMgr.getFormattedDecimal(totPrecioVenta)%></td>
              <td align="center"><%=CmnMgr.getFormattedDecimal(totCosto)%></td>
              <td align="right" colspan="2"></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro </cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>


<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="23">Usos del Procedimiento</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="53%">Nombre</td>
							<td width="10%"><cellbytelabel id="30">Tipo</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="22">Cantidad</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="22">Precio</cellbytelabel></td>
							<td width="9%"><cellbytelabel id="22">Costo</cellbytelabel></td>
							<td width="5%"><%=fb.submit("btnaddUso","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Usos")%></td>
						</tr>
						<%
						al = CmnMgr.reverseRecords(iUso);
						totPrecioVenta  = 0; totCosto = 0;
						for (int i=1; i<=iUso.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdo = (CommonDataObject) iUso.get(key);
							
							totPrecioVenta += Double.parseDouble(cdo.getColValue("precio_venta","0"));
							totCosto += Double.parseDouble(cdo.getColValue("costo","0"));
						%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("cod_uso"+i,cdo.getColValue("cod_uso"))%>
						<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("cod_uso")%></td>
														<td><%=cdo.getColValue("observacion")%></td>
							<td><%=fb.select("tipo_uso"+i,"M=MANUAL,A=AUTOMATICO",cdo.getColValue("tipo_uso"),false,false,0,"Text10",null,null,null,"")%></td>
							<td><%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,false,10,2)%></td>
							<td align="center"><b><%=cdo.getColValue("precio_venta")%></b></td>
							<td align="center"><b><%=cdo.getColValue("costo")%></b></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Uso")%></td>
						</tr>
						<%
						}
					%>
					<tr class="TextHeader02">
              <td align="right" colspan="4">Total</td>
              <td align="center"><%=CmnMgr.getFormattedDecimal(totPrecioVenta)%></td>
              <td align="center"><%=CmnMgr.getFormattedDecimal(totCosto)%></td>
              <td align="right"></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro </cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>


<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="24">Personal del Procedimiento</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel40">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="65%"><cellbytelabel id="21">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="22">Cantidad</cellbytelabel></td>
							<td width="5%"><%=fb.submit("btnaddPers","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Personal")%></td>
						</tr>
						<%
						al = CmnMgr.reverseRecords(iPers);
						for (int i=1; i<=iPers.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdo = (CommonDataObject) iPers.get(key);
						%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("cod_funcion"+i,cdo.getColValue("cod_funcion"))%>
						<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("cod_funcion")%></td>
														<td><%=cdo.getColValue("descripcion")%></td>
							<td><%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,false,10,2)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Personal")%></td>
						</tr>
						<%
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro </cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>


<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="25">Honorarios del Procedimiento</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel50">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="65%"><cellbytelabel id="21">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="12">Precio</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="13">Costo</cellbytelabel></td>
							<td width="5%"><%=fb.submit("btnaddHon","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Honorario")%></td>
						</tr>
						<%
						al = CmnMgr.reverseRecords(iHon);
						for (int i=1; i<=iHon.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdo = (CommonDataObject) iHon.get(key);
						%>
						<%=fb.hidden("key"+i,key)%>
						<%=fb.hidden("cod_tipo_honorario"+i,cdo.getColValue("cod_tipo_honorario"))%>
						<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("cod_tipo_honorario")%></td>
														<td><%=cdo.getColValue("descripcion")%></td>
							<td><%=fb.decBox("precio"+i,cdo.getColValue("precio"),true,false,false,15,8.2)%></td>
							<td><%=fb.decBox("costo"+i,cdo.getColValue("costo"),false,false,false,15,8.2)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Honorario")%></td>
						</tr>
						<%
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>

<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="26">Malet&iacute;n de Anestesia</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel id="27">Indique el Malet&iacute;n de Anestesia</cellbytelabel>:</td>
							<td width="80%" align="left">
							<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_maletin", "tipo_maletin_anestesia", proc.getColValue("tipo_maletin_anestesia"),false,false,0,"S")%>
							</td>
						</tr>
						<%
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>

<!-- TAB7 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;else if("+iNP.size()+"==0){error++;CBMSG.warning('Por favor agregar por lo menos (1) Nivel de Precio!');}");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("colSize",""+iCol.size())%>
<%=fb.hidden("colLastLineNo",""+colLastLineNo)%>
<%=fb.hidden("insSize",""+iIns.size())%>
<%=fb.hidden("insLastLineNo",""+insLastLineNo)%>
<%=fb.hidden("usoSize",""+iUso.size())%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("honSize",""+iHon.size())%>
<%=fb.hidden("honLastLineNo",""+honLastLineNo)%>
<%=fb.hidden("NPSize",""+iNP.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="28">Niveles de Precio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel70">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%" rowspan="2"><cellbytelabel id="29">Nivel</cellbytelabel></td>
							<td width="25%" rowspan="2"><cellbytelabel id="8">Nombre</cellbytelabel></td>
							<td width="10%" rowspan="2"><cellbytelabel id="30">Tipo</cellbytelabel></td>
							<td width="10%" rowspan="2"><cellbytelabel id="31">Tipo Cod.</cellbytelabel></td>
							<td width="10%" rowspan="2"><cellbytelabel id="12">Precio</cellbytelabel></td>
							<td width="30%" colspan="4"><cellbytelabel id="32">Oferta</cellbytelabel></td>
							<td width="2%" rowspan="2"><%=fb.submit("btnaddHon","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Honorario")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="12">Precio</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="33">Fecha Ini</cellbytelabel>.</td>
							<td width="10%"><cellbytelabel id="34">Fecha Fin</cellbytelabel></td>
							<td width="3%"><cellbytelabel id="35">Aplica Emp</cellbytelabel>.</td>
						</tr>

						<%
						String fecha_ini = "", fecha_fin = "";
						al = CmnMgr.reverseRecords(iNP);
						for (int i=0; i<iNP.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdo = (CommonDataObject) iNP.get(key);
							fecha_ini = "fecha_ini_oferta"+i;
							fecha_fin = "fecha_fin_oferta"+i;
						%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("ref_type_"+i,cdo.getColValue("ref_type"))%>
						<%=fb.hidden("ref_table"+i,cdo.getColValue("ref_table"))%>
						<tr class="TextRow01">
							<td><%=fb.textBox("nivel"+i,cdo.getColValue("nivel"),true,false,true,7,"Text10",null,null)%></td>
							<td><%=fb.textBox("nivel_nombre"+i,cdo.getColValue("nivel_nombre"),true,false,false,40,"Text10",null,null)%></td>
							<td><%=fb.select("ref_type"+i,"1=Empresa,2=Centro de Servicio, 3=Categoria Admision",cdo.getColValue("ref_type"),false,false,0,"Text10","","onChange=\"javascript:chkRefType("+i+");\"")%></td>
							<td id="ECS<%=i%>" <%=(cdo.getColValue("ref_type").equals("3")?"style=\"display:none\"":"")%>>
							<%=fb.textBox("ref_code"+i,cdo.getColValue("ref_code"),true,false,true,10,"Text10",null,"onDblClick=\"javascripg:clearRC("+i+");\"")%>
							<%=fb.button("btnRef"+i,"...",true,false,null,"Text10","onClick=\"javascript:showRef("+i+");\"")%>
							</td>
							<td id="TCA<%=i%>"
							<%=(cdo.getColValue("ref_type").equals("3")?"":"style=\"display:none\"")%>><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_adm_categoria_admision order by descripcion","ref_code_2"+i,cdo.getColValue("ref_code"),false,false,0,"Text10","","")%></td>
							<td><%=fb.decBox("precio"+i,cdo.getColValue("precio"),true,false,false,10,8.2, "text10", "", "")%></td>
							<td><%=fb.decBox("precio_oferta"+i,cdo.getColValue("precio_oferta"),false,false,false,10,8.2, "text10", "", "")%></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="<%=fecha_ini%>"/>
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_ini_oferta")%>"/>
								<jsp:param name="fieldClass" value="Text10"/>
								<jsp:param name="buttonClass" value="Text10"/>
								</jsp:include>
							</td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="<%=fecha_fin%>"/>
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fin_oferta")%>"/>
								<jsp:param name="fieldClass" value="Text10"/>
								<jsp:param name="buttonClass" value="Text10"/>
								</jsp:include>
							</td>
							<td><%=fb.select("oferta_aplica_emp"+i,"S=Sí,N=No",cdo.getColValue("oferta_aplica_emp"),false,false,0,"Text10","","")%></td>
							<td align="center"><%//=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Honorario")%></td>
						</tr>
						<%
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro </cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Procedimientos'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Procedimientos','Insumos','Usos','Personal','Honorarios','Maletin Anestesia','Niveles de Precio'),<%=tab%>,'100%','');
<%
}
%>
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0")) //PROCEDIMIENTO
	{
		proc = new CommonDataObject();

		proc.setTableName("tbl_cds_procedimiento");
		proc.addColValue("descripcion",request.getParameter("descripcion"));
		proc.addColValue("estado",request.getParameter("estado"));

		proc.addColValue("tipo_categoria",request.getParameter("tipo_categoria"));
		proc.addColValue("observacion",request.getParameter("observacion"));
		proc.addColValue("tiempo_estimado",request.getParameter("tiempo_estimado"));
		proc.addColValue("unidad_tiempo",request.getParameter("unidad_tiempo"));
		proc.addColValue("precio",request.getParameter("precio"));
		proc.addColValue("precio_oferta",request.getParameter("precio_oferta"));
		proc.addColValue("costo",request.getParameter("costo"));
		proc.addColValue("costo_ref",request.getParameter("costo_ref"));
		if(request.getParameter("nombre_corto")!=null) proc.addColValue("nombre_corto",request.getParameter("nombre_corto"));
		/*
		proc.addColValue("precio2",request.getParameter("precio2"));
		proc.addColValue("precio_oferta2",request.getParameter("precio_oferta2"));
		proc.addColValue("costo2",request.getParameter("costo2"));
		proc.addColValue("precio3",request.getParameter("precio3"));
		proc.addColValue("precio_oferta3",request.getParameter("precio_oferta3"));
		proc.addColValue("costo3",request.getParameter("costo3"));
		proc.addColValue("precio4",request.getParameter("precio4"));
		proc.addColValue("precio_oferta4",request.getParameter("precio_oferta4"));
		proc.addColValue("costo4",request.getParameter("costo4"));
		proc.addColValue("precio5",request.getParameter("precio5"));
		proc.addColValue("precio_oferta5",request.getParameter("precio_oferta5"));
		proc.addColValue("costo5",request.getParameter("costo5"));
		proc.addColValue("cod_cds",request.getParameter("cod_cds"));
		proc.addColValue("cod_cds2",request.getParameter("cod_cds2"));
		proc.addColValue("cod_cds3",request.getParameter("cod_cds3"));
		proc.addColValue("cod_cds4",request.getParameter("cod_cds4"));
		proc.addColValue("cod_cds5",request.getParameter("cod_cds5"));
		
		System.out.println("nombre_corto="+request.getParameter("nombre_corto"));
		*/

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		if (mode.equalsIgnoreCase("add"))
		{

			proc.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			proc.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			proc.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			proc.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			proc.addColValue("codigo",request.getParameter("codigo"));
			SQLMgr.insert(proc);
			id = request.getParameter("codigo");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			proc.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			proc.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			proc.setWhereClause("codigo='"+id+"'");
			SQLMgr.update(proc);
			id = request.getParameter("codigo");
		}
		ConMgr.clearAppCtx(null);

		sql = "select a.codigo value_col, a.descripcion label_col, b.cod_centro_servicio key_col from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo = b.cod_procedimiento";
		IXml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+"/cpt.xml", sql);

	} //END TAB 0
	else if (tab.equals("1")) //INSUMOS
	{
		int size = 0;
		if (request.getParameter("insSize") != null) size = Integer.parseInt(request.getParameter("insSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
				CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_insumo_x_proc");
			cdo.setWhereClause("cod_proced='"+id+"'");
			cdo.setAutoIncWhereClause("cod_proced='"+id+"'");
			cdo.addColValue("cod_proced",id);
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("art_familia",request.getParameter("familyCode"+i));

			cdo.addColValue("art_clase",request.getParameter("classCode"+i));
			cdo.addColValue("articulo",request.getParameter("itemCode"+i));
			cdo.addColValue("descripcion",request.getParameter("item"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("code",request.getParameter("code"+i));
			if(request.getParameter("paquete"+i)!=null) cdo.addColValue("paquete", "S");

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getColValue("key");
			}
			else
			{
				try
				{
					iIns.put(request.getParameter("key"+i),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
				vIns.remove(((CommonDataObject) iIns.get(itemRemoved)).getColValue("code"));
						iIns.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

				if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_insumo_x_proc");
			cdo.setWhereClause("cod_proced='"+id+"'");

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	} //END TAB 2
	else if (tab.equals("2")) //USOS
	{
		int size = 0;
		if (request.getParameter("usoSize") != null) size = Integer.parseInt(request.getParameter("usoSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_activo_x_proc");
			cdo.setWhereClause("procedimiento='"+id+"'");
			cdo.setAutoIncWhereClause("procedimiento='"+id+"'");
			cdo.addColValue("cod_uso",request.getParameter("cod_uso"+i));
			cdo.addColValue("procedimiento",id);
			cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
			cdo.addColValue("tipo_uso",request.getParameter("tipo_uso"+i));
			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getColValue("key");
			}
			else
			{
				try
				{
					iUso.put(request.getParameter("key"+i),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vUso.remove(((CommonDataObject) iUso.get(itemRemoved)).getColValue("cod_uso"));
					iUso.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_activo_x_proc");
			cdo.setWhereClause("procedimiento='"+id+"'");

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	} //END TAB 3
	else if (tab.equals("3")) //PERSONAL
	{
		int size = 0;
		if (request.getParameter("persSize") != null) size = Integer.parseInt(request.getParameter("persSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_personal_x_proc");
			cdo.setWhereClause("cod_procedimiento='"+id+"'");
			cdo.setAutoIncWhereClause("cod_procedimiento='"+id+"'");
			cdo.addColValue("cod_funcion",request.getParameter("cod_funcion"+i));
			cdo.addColValue("cod_procedimiento",id);
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));

			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getColValue("key");
			}
			else
			{
				try
				{
					iPers.put(request.getParameter("key"+i),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vPers.remove(((CommonDataObject) iPers.get(itemRemoved)).getColValue("cod_funcion"));
					iPers.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_personal_x_proc");
			cdo.setWhereClause("cod_procedimiento='"+id+"'");

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	} //END TAB 4
	else if (tab.equals("4")) //HONORARIOS
	{
		int size = 0;
		if (request.getParameter("honSize") != null) size = Integer.parseInt(request.getParameter("honSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_honorario_x_proc");
			cdo.setWhereClause("cod_procedimiento='"+id+"'");
			cdo.setAutoIncWhereClause("cod_procedimiento='"+id+"'");
			cdo.addColValue("cod_tipo_honorario",request.getParameter("cod_tipo_honorario"+i));
			cdo.addColValue("cod_procedimiento",id);
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("precio",request.getParameter("precio"+i));

			cdo.addColValue("costo",request.getParameter("costo"+i));

			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{

				itemRemoved = cdo.getColValue("key");
			}
			else
			{
				try
				{
					iHon.put(request.getParameter("key"+i),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vHon.remove(((CommonDataObject) iHon.get(itemRemoved)).getColValue("cod_tipo_honorario"));
					iHon.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&type=1&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_honorario_x_proc");
			cdo.setWhereClause("cod_procedimiento='"+id+"'");

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	} //END TAB 5
	else if (tab.equals("5")) //PROCEDIMIENTO
	{
		proc = new CommonDataObject();

		proc.setTableName("tbl_cds_procedimiento");
		if(request.getParameter("tipo_maletin_anestesia")!=null && !request.getParameter("tipo_maletin_anestesia").trim().equals("")) proc.addColValue("tipo_maletin_anestesia",request.getParameter("tipo_maletin_anestesia"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode=edit&id="+id+"&tab="+tab);
		if (mode.equalsIgnoreCase("edit"))
		{
			proc.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			proc.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			proc.setWhereClause("codigo='"+id+"'");
			SQLMgr.update(proc);
		}
		ConMgr.clearAppCtx(null);

	}
	else if (tab.equals("6")) //NIVEL DE PRECIO
	{
		int size = 0;
		if (request.getParameter("NPSize") != null) size = Integer.parseInt(request.getParameter("NPSize"));
		String itemRemoved = "";

		al.clear();
		iNP.clear();
		int lineNo = 0;
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_fac_nivel_precio");
			cdo.setAutoIncCol("nivel");
			cdo.addPkColValue("nivel","");
			cdo.setWhereClause("cargo_code = '"+id+"'");
			cdo.setAutoIncWhereClause("cargo_code is not null");
			cdo.addColValue("nivel",request.getParameter("nivel"+i));
			cdo.addColValue("ref_type",request.getParameter("ref_type"+i));
			cdo.addColValue("ref_code",request.getParameter("ref_code"+i));
			if(cdo.getColValue("ref_type").equals("3")) cdo.addColValue("ref_code",request.getParameter("ref_code_2"+i));
			if(cdo.getColValue("ref_type").equals("1")) cdo.addColValue("ref_table","tbl_adm_empresa");
			else if(cdo.getColValue("ref_type").equals("2")) cdo.addColValue("ref_table","tbl_cds_centro_servicio");
			else if(cdo.getColValue("ref_type").equals("3")) cdo.addColValue("ref_table","tbl_adm_categoria_admision");
			cdo.addColValue("cargo_code",id);
			cdo.addColValue("cargo_servicio","7");
			cdo.addColValue("nivel_nombre",request.getParameter("nivel_nombre"+i));
			cdo.addColValue("precio",request.getParameter("precio"+i));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			if(request.getParameter("precio_oferta"+i)!=null && !request.getParameter("precio_oferta"+i).equals("")){
				cdo.addColValue("precio_oferta",request.getParameter("precio_oferta"+i));
				cdo.addColValue("fecha_ini_oferta",request.getParameter("fecha_ini_oferta"+i));
				cdo.addColValue("fecha_fin_oferta",request.getParameter("fecha_fin_oferta"+i));
				cdo.addColValue("oferta_aplica_emp",request.getParameter("oferta_aplica_emp"+i));
			} else {
				cdo.addColValue("fecha_ini_oferta","");
				cdo.addColValue("fecha_fin_oferta","");
				cdo.addColValue("oferta_aplica_emp","N");
			}

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{

				itemRemoved = cdo.getColValue("nivel");
			}
			else
			{
				try
				{
				lineNo++;
				if (lineNo < 10) key = "00" + lineNo;
				else if (lineNo < 100) key = "0" + lineNo;
				else key = "" + lineNo;
					iNP.put(key,cdo);
					vNP.addElement(cdo.getColValue("ref_type")+"-"+cdo.getColValue("ref_code")+"-"+cdo.getColValue("cargo_servicio")+"-"+cdo.getColValue("cargo_code"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vNP.remove(((CommonDataObject) iNP.get(itemRemoved)).getColValue("nivel"));
					iNP.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=6&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			System.out.println();
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("nivel","0");
			cdo.addColValue("ref_type","1");
			cdo.addColValue("ref_code","");
			cdo.addColValue("ref_table","");
			cdo.addColValue("cargo_code",id);
			cdo.addColValue("nivel_nombre","");
			cdo.addColValue("precio","");
			cdo.addColValue("precio_oferta","");
			cdo.addColValue("fecha_ini_oferta","");
			cdo.addColValue("fecha_fin_oferta","");
			cdo.addColValue("oferta_aplica_emp","");
			cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			iNP.put(cdo.getColValue("ref_type")+"-"+cdo.getColValue("ref_code")+"-"+cdo.getColValue("cargo_servicio")+"-"+cdo.getColValue("cargo_code"),cdo);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=6&type=1&mode="+mode+"&id="+id+"&colLastLineNo="+colLastLineNo+"&insLastLineNo="+insLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&persLastLineNo="+persLastLineNo+"&honLastLineNo="+honLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_fac_nivel_precio");
			cdo.setWhereClause("nivel='"+id+"'");

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&id="+id+"&tab="+tab);
		SQLMgr.insertList(al, true, true);
		ConMgr.clearAppCtx(null);
	} //END TAB 6
%>
<html>
<head>
<script language="javascript" src="../common/header_param_min.jsp"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/procedimientos_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/procedimientos_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/procedimientos_list.jsp';
<%
		}
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>