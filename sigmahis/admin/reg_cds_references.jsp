<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iTServ" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vTServ" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iUser" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUser" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iTAdm" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vTAdm" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iPam" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iProce" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProce" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iWH" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vWH" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iProdCds" scope="session" class="java.util.Hashtable"/>
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

ArrayList al = new ArrayList();
CommonDataObject cds = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alCds = new ArrayList();
ArrayList alTs = new ArrayList();
ArrayList alUm = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String key = "";
String tab = request.getParameter("tab");
String change = request.getParameter("change");
int tServLastLineNo = 0;
int userLastLineNo = 0;
int tAdmLastLineNo = 0;
int pamLastLineNo = 0;
int procLastLineNo = 0;
int docLastLineNo = 0;
int whLastLineNo = 0;
if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (request.getParameter("tServLastLineNo") != null) tServLastLineNo = Integer.parseInt(request.getParameter("tServLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));
if (request.getParameter("tAdmLastLineNo") != null) tAdmLastLineNo = Integer.parseInt(request.getParameter("tAdmLastLineNo"));
if (request.getParameter("pamLastLineNo") != null) pamLastLineNo = Integer.parseInt(request.getParameter("pamLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("whLastLineNo") != null) whLastLineNo = Integer.parseInt(request.getParameter("whLastLineNo"));
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	alCds = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio  where estado = 'A' and origen = 'S' union select codigo, descripcion, codigo from tbl_cds_centro_servicio where codigo = "+id+" order by 2",CommonDataObject.class);
	alTs = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn from tbl_cds_tipo_servicio order by 1 ",CommonDataObject.class);
	alUm = sbb.getBeanList(ConMgr.getConnection(),"select cod_medida as optValueColumn, descripcion as optLabelColumn from tbl_inv_unidad_medida order by 1 ",CommonDataObject.class);


	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		iTServ.clear();
		vTServ.clear();
		iUser.clear();
		vUser.clear();
		iTAdm.clear();
		vTAdm.clear();
		iPam.clear();
		iProce.clear();
		vProce.clear();
		iDoc.clear();
		vDoc.clear();
		iWH.clear();
		vWH.clear();
		iProdCds.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");

		sql = "select codigo, descripcion, si_no from tbl_cds_centro_servicio where codigo="+id+" order by 2";
		cds = SQLMgr.getData(sql);

		if (change == null)
		{
			iTServ.clear();
			vTServ.clear();
			iUser.clear();
			vUser.clear();
			iTAdm.clear();
			vTAdm.clear();
			iPam.clear();
			iProce.clear();
			vProce.clear();
			iDoc.clear();
				vDoc.clear();
			iWH.clear();
			vWH.clear();
			iProdCds.clear();

			sql = "select a.tipo_servicio as tipoServicio, a.centro_servicio as centroServicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as tipoServicioDesc,nvl(a.visible_centro,'N')visibleCentro from tbl_cds_servicios_x_centros a where a.centro_servicio="+id+" order by 3";
			al  = SQLMgr.getDataList(sql);
			tServLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iTServ.put(key, cdo);
					vTServ.addElement(cdo.getColValue("tipoServicio"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			if (cds.getColValue("si_no").equalsIgnoreCase("S"))
			{
				sql = "select a.cds, a.user_id, (select user_name from tbl_sec_users where user_id=a.user_id) as user_name, (select name from tbl_sec_users where user_id=a.user_id) as name, nvl(a.comments,' ') as comments from tbl_sec_user_cds a where a.cds="+id+" order by 3";
				al  = SQLMgr.getDataList(sql);

				userLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i-1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;
					cdo.addColValue("key",key);

					try
					{
						iUser.put(key, cdo);
						vUser.addElement(cdo.getColValue("user_id"));
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}

				sql = "select a.cod_centro as codCentro, a.cod_categoria as codCategoria, a.cod_tipo as codTipo, (select descripcion from tbl_adm_tipo_admision_cia where categoria=a.cod_categoria and codigo=a.cod_tipo) as tipoAdmisionDesc, (select descripcion from tbl_adm_categoria_admision where codigo=a.cod_categoria) as categoriaDesc, a.cds_atencion as cdsAtencion, a.estado_ini_atencion as estadoIniAtencion, a.prioridad_ris as prioridadRis from tbl_adm_tipo_admision_x_cds a where a.cod_centro="+id+" order by 5, 4";

				al  = SQLMgr.getDataList(sql);
				tAdmLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i-1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;
					cdo.addColValue("key",key);

					try
					{
						iTAdm.put(key, cdo);
						vTAdm.addElement(cdo.getColValue("codCategoria")+"-"+cdo.getColValue("codTipo"));
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
			}

//-------------------------  PRODUCTOS PAM---------------------------------------------------
sql = "select a.codigo as codigo ,a.referencia as referencia ,a.descripcion as descripcion,a.precio as precio, a.compania as compania, a.cod_centro_servicio as cod_centro  from tbl_pamd_productos a where a.cod_centro_servicio="+id+"order by  3" ;

				al  = SQLMgr.getDataList(sql);
				pamLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
					{
						CommonDataObject cdo = (CommonDataObject) al.get(i-1);
							if (i < 10) key = "00" + i;
							else if (i < 100) key = "0" + i;
							else key = "" + i;
							cdo.addColValue("key",key);

						try
						{
							iPam.put(key, cdo);
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}

///----------------------------pamd--------------------------------------

				sbFilter = new StringBuffer();
				if (request.getParameter("procCode") != null && !request.getParameter("procCode").trim().equals("")) { sbFilter.append(" and a.cod_procedimiento = '"); sbFilter.append(IBIZEscapeChars.forSingleQuots(request.getParameter("procCode"))); sbFilter.append("%'"); }
				if (request.getParameter("procDesc") != null && !request.getParameter("procDesc").trim().equals("")) { /*;*/sbFilter.append(" and exists (select null from tbl_cds_procedimiento where codigo = a.cod_procedimiento and upper(descripcion) like '%"); sbFilter.append(IBIZEscapeChars.forSingleQuots(request.getParameter("procDesc")).toUpperCase()); sbFilter.append("%')"); }

				sbSql = new StringBuffer();
				sbSql.append("select a.cod_centro_servicio as codCentroServicio, a.cod_procedimiento as codProcedimiento, a.precio, decode(a.costo,null,' ',a.costo) as costo, nvl(a.usado_por_cu,' ') as usadoPorCu, (select coalesce(observacion, descripcion) from tbl_cds_procedimiento where codigo = a.cod_procedimiento) as procedimientoDesc,decode(a.display_order,null,' ',a.display_order) as display_order, nvl(a.display_qty,'N') as display_qty, nvl(a.display_freq,'N') as display_freq, nvl(a.display_vol,'N') as display_vol, nvl(a.display_rsn,'N') as display_rsn, nvl(a.display_prior,'N') as display_prior from tbl_cds_procedimiento_x_cds a where a.cod_centro_servicio = ");
				sbSql.append(id);
				sbSql.append(sbFilter);
				sbSql.append(" order by 6");
				al  = SQLMgr.getDataList(sbSql.toString());

				procLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++) {
					CommonDataObject cdo = (CommonDataObject) al.get(i-1);

					cdo.setKey(i);

					try {
						iProce.put(cdo.getKey(), cdo);
						vProce.addElement(cdo.getColValue("codProcedimiento"));
					} catch(Exception e) {
						System.err.println(e.getMessage());
					}
				}

//----------------------------documentos--------------------------------------

sql="select a.id, a.description,a.name,a.status from tbl_sal_exp_docs a,tbl_sal_exp_docs_cds b where a.status ='A' and b.cds_code="+id+" and a.id=b.doc_id  order by id asc";

				al  = SQLMgr.getDataList(sql);
				docLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i-1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;
					cdo.addColValue("key",key);

					try
					{
						iDoc.put(key, cdo);
						vDoc.addElement(cdo.getColValue("id"));
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
//----------------------------documentos--------------------------------------
//----------------------------ALMACENES--------------------------------------

				sql="select a.cds, a.almacen as codigo_almacen, a.compania, a.comments, a.is_bm, (select descripcion from tbl_inv_almacen where compania=a.compania and codigo_almacen=a.almacen) as desc_Almacen, (select nombre from tbl_sec_compania where codigo=a.compania) as compania_name from tbl_sec_cds_almacen a where a.cds="+id+" order by 2";
				al  = SQLMgr.getDataList(sql);
				whLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i-1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;
					cdo.addColValue("key",key);

					try
					{
						iWH.put(key, cdo);
						vWH.addElement(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_almacen"));
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
//----------------------------fin almacen--------------------------------------

sql="select t.codigo,t.codigo codigoReg, t.cod_centro_servicio cds,t.um_cod_medida um_cod_medida,t.descripcion, t.precio, t.tser, t.cpt, t.estatus, to_char(t.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,t.usuario_creacion,t.costo,t.incremento,t.cod_internacional,t.codigo_producto_axa,t.origen_codigo from tbl_cds_producto_x_cds t where t.cod_centro_servicio= "+id+" order by 1";
				al  = SQLMgr.getDataList(sql);
				//whLastLineNo = al.size();
				for(int h=0;h<al.size();h++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(h);
					cdo.setKey(h);
					cdo.setAction("U");
					try
					{
						iProdCds.put(cdo.getKey(), cdo);
						//vProdCds.addElement(cdo.getColValue("cds")+"-"+cdo.getColValue("codigo_almacen"));
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
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Referencia Centro de Servicios -- Productos- '+document.title;
function showDocumentosList(tab)
{
	abrir_ventana1('../common/check_exp_documentos.jsp?fp=cds_references&mode=<%=mode%>&tab='+tab+'&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>');
}
function showAlmacenList(tab)
{
	abrir_ventana1('../common/check_almacen.jsp?fp=cds_references&mode=<%=mode%>&tab='+tab+'&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>');
}
function showTipoServicioList(tab)
{
	abrir_ventana1('../common/check_tipo_servicio.jsp?fp=cds_references&mode=<%=mode%>&tab='+tab+'&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>');
}

function showUserList(tab)
{
	abrir_ventana1('../common/check_user.jsp?fp=cds_references&mode=<%=mode%>&tab='+tab+'&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>');
}

function showTipoAdmisionList(tab)
{
	abrir_ventana1('../common/check_tipo_admision.jsp?fp=cds_references&mode=<%=mode%>&tab='+tab+'&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>');
}

function showProcedimientoList(tab)
{
	abrir_ventana1('../common/check_procedimiento.jsp?fp=cds_references&mode=<%=mode%>&id=<%=id%>&tab='+tab+'&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>');
}

function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
	showUserList(<%=tab%>);
<%
		}
		else if (tab.equals("5"))
		{
%>
	showAlmacenList(<%=tab%>);
<%
		}
	}
%>
}
function validExp(){
   var ok=true;for(i=1;i<=<%=iTAdm.size()%>;i++){
     if (eval('document.form2.estadoIniAtencion'+i).value == "Z"){
	   ok=true;
	 }else{
		if((eval('document.form2.cdsAtencion'+i).value.trim()!=''&&eval('document.form2.estadoIniAtencion'+i).value.trim()=='')||(eval('document.form2.cdsAtencion'+i).value.trim()==''&&eval('document.form2.estadoIniAtencion'+i).value.trim()!='')){ok=false;break;}
	 }
   }
	 return ok;
}
function updAction(fName,idx){if(eval('document.'+fName+'.iAction'+idx).value!='I')eval('document.'+fName+'.iAction'+idx).value='U';}
function _doUpdProcPrice(){var uAction=document.form3.uAction.value;var uValue=document.form3.uValue.value;var uType=document.form3.uType.value;if(uAction.trim()==''){CBMSG.alert('Por favor seleccione la ACCION!');return false;}else uAction=parseInt(uAction,10);if(uValue.trim()=='')uValue=0;else if(uType=='P')uValue=1+(parseFloat(uValue)/100);else uValue=parseFloat(uValue);for(i=1;i<=<%=iProce.size()%>;i++){if(eval('document.form3.iAction'+i).value!='D'){var newPrice=0;if(uType=='P')newPrice=parseFloat(eval('document.form3.precio'+i).value)*uAction*uValue;else newPrice=parseFloat(eval('document.form3.precio'+i).value)+(uAction*uValue);if(newPrice>0){eval('document.form3.precio'+i).value=newPrice.toFixed(2);updAction('form3',i);}}}}
function printProcList(opt){if(!opt)abrir_ventana('../admin/print_procedimiento_x_cds.jsp?cds=<%=id%>');else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admin/print_procedimiento_x_cds.rptdesign&cds=<%=id%>&cds_desc=<%=cds.getColValue("codigo")+" - "+cds.getColValue("descripcion")%>&pCtrlHeader=false');}

function doUpdProcPrice(){
  var uAction=document.form3.uAction.value;
  var uValue=document.form3.uValue.value;
  var uType=document.form3.uType.value;
  
  if(!uAction.trim()){
     CBMSG.error('Por favor seleccione la ACCION!');
     return false;
  }
  
  if(!$.isNumeric(uValue)){
     CBMSG.error('Valor inválido!!');
     return false;
  }
  
  for(i=1;i<=<%=iProce.size()%>;i++){
    if(document.getElementById("iAction"+i).value != 'D'){
       var newPrice=0;
       var basePrice = parseFloat(document.getElementById("precio"+i).value);
       uValue = parseFloat(uValue);
       
       if (uType=='P') {
        if (uAction == 1) newPrice = basePrice + (uValue * basePrice / 100);
        else newPrice = basePrice - (uValue * basePrice / 100);
       }
       else {
        if (uAction == 1) newPrice = basePrice + uValue;
        else newPrice = basePrice - uValue;
       }
       
       if(newPrice>=0){
          document.getElementById("precio"+i).value=newPrice.toFixed(2);
          updAction('form3',i);
       }
    }
  }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REFERENCIAS CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td>
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("tab","0")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("tServSize",""+iTServ.size())%>
		<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
		<%=fb.hidden("userSize",""+iUser.size())%>
		<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
		<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
		<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
		<%=fb.hidden("pamSize",""+iPam.size())%>
		<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
		<%=fb.hidden("iProceSize",""+iProce.size())%>
		<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
		<%=fb.hidden("iDocSize",""+iDoc.size())%>
		<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
		<%=fb.hidden("iWHSize",""+iWH.size())%>
		<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Tipo de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="65%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Visible CDS</cellbytelabel></td>
							<td width="5%"><%=fb.button("addTipoServicio","+",true,false,null,null,"onClick=\"javascript:showTipoServicioList(0)\"","Agregar Tipos de Servicios")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iTServ);
for (int i=1; i<=iTServ.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo = (CommonDataObject) iTServ.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("tipoServicio"+i,cdo.getColValue("tipoServicio"))%>
						<%=fb.hidden("tipoServicioDesc"+i,cdo.getColValue("tipoServicioDesc"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("tipoServicio")%></td>
							<td><%=cdo.getColValue("tipoServicioDesc")%></td>
							<td align="center"><%=fb.checkbox("visibleCentro"+i,"S",(cdo.getColValue("visibleCentro") != null && cdo.getColValue("visibleCentro").equalsIgnoreCase("S")),false)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>


<%
if (cds.getColValue("si_no").equalsIgnoreCase("S"))
{
%>


<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tServSize",""+iTServ.size())%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userSize",""+iUser.size())%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamSize",""+iPam.size())%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("iProceSize",""+iProce.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("iDocSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Usuario</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel>Usuario</cellbytelabel></td>
							<td width="40%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="40%"><cellbytelabel>Comentarios</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addUser","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Usuarios")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iUser);
for (int i=1; i<=iUser.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo = (CommonDataObject) iUser.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("user_id"+i,cdo.getColValue("user_id"))%>
						<%=fb.hidden("user_name"+i,cdo.getColValue("user_name"))%>
						<%=fb.hidden("name"+i,cdo.getColValue("name"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("user_name")%></td>
							<td><%=cdo.getColValue("name")%></td>
							<td align="center"><%=fb.textBox("comments"+i,cdo.getColValue("comments"),false,false,false,50)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>


<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document.form2.baction.value=='Guardar'&&!validExp()){error++;alert('Si el Tipo de Admisión maneja Expediente, por favor indique el Centro y Estado Inicial de la atención');}");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tServSize",""+iTServ.size())%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userSize",""+iUser.size())%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamSize",""+iPam.size())%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("iProceSize",""+iProce.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("iDocSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Tipo de Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Categor&iacute;a de Admisi&oacute;n</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Tipo de Admisi&oacute;n</cellbytelabel></td>
							<td width="23%"><cellbytelabel>CDS Atenci&oacute;n</cellbytelabel></td>
							<td width="14%"><cellbytelabel>Estado Inicial de Atenci&oacute;n</cellbytelabel></td>
							<td width="3%"><%=fb.button("addTipoAdmision","+",true,false,null,null,"onClick=\"javascript:showTipoAdmisionList(2)\"","Agregar Tipos de Admisiones")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iTAdm);
for (int i=1; i<=iTAdm.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo = (CommonDataObject) iTAdm.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("codCategoria"+i,cdo.getColValue("codCategoria"))%>
						<%=fb.hidden("categoriaDesc"+i,cdo.getColValue("categoriaDesc"))%>
						<%=fb.hidden("codTipo"+i,cdo.getColValue("codTipo"))%>
						<%=fb.hidden("tipoAdmisionDesc"+i,cdo.getColValue("tipoAdmisionDesc"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("codCategoria")%></td>
							<td><%=cdo.getColValue("categoriaDesc")%></td>
							<td><%=cdo.getColValue("codTipo")%></td>
							<td><%=cdo.getColValue("tipoAdmisionDesc")%></td>
							<td align="center"><%=fb.select("cdsAtencion"+i,alCds,cdo.getColValue("cdsAtencion"),false,false,0,"S")%></td>
							<td align="center"><%=fb.select("estadoIniAtencion"+i,"E=EN ESPERA,P=PROCESO,Z=NO HABILITADO",cdo.getColValue("estadoIniAtencion"),false,false,0,"S")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction(this.form.name,this.value);\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

</table>

<!-- TAB2 DIV END HERE-->
</div>

<%
}
%>

<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tServSize",""+iTServ.size())%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userSize",""+iUser.size())%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamSize",""+iPam.size())%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("iProceSize",""+iProce.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("iDocSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>
				<tr class="TextRow02">
					<td align="right">
						&nbsp;<a href="javascript:printProcList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
						&nbsp;<a href="javascript:printProcList(1)" class="Link00">[ <cellbytelabel>Excel</cellbytelabel> ]</a>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel40">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(42)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Actualizaci&oacute;n de Precios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus42" style="display:none">+</label><label id="minus42">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel42">
					<td class="TextHeader01" align="center">
						<cellbytelabel>Acci&oacute;n</cellbytelabel>: <%=fb.select("uAction","1=INCREMENTAR,-1=DECREMENTAR","",false,false,false,0,"S")%>
						<cellbytelabel>Valor</cellbytelabel>: <%=fb.decBox("uValue","",false,false,false,8,6.2,null,null,null)%> <%=fb.select("uType","P=%,M=$","",false,false,false,0,"")%>
						<%=fb.button("uApply","Aplicar",true,false,null,null,"onClick=\"javascript:doUpdProcPrice()\"")%>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Procedimientos x Centro Servicios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
						</tr>

						</table>
					</td>
				</tr>
				<tr id="panel41">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%" rowspan="2"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="40%" rowspan="2"><cellbytelabel>Procedimiento</cellbytelabel></td>
							<td width="10%" rowspan="2"><cellbytelabel>Precio</cellbytelabel></td>
							<td width="10%" rowspan="2"><cellbytelabel>Costo</cellbytelabel></td>
							<td width="25%" colspan="6" >Par&aacute;m. Exp. (Examenes/Solicitudes)</td>
							<td width="5%" rowspan="2"><%=fb.button("addProcedimiento","+",true,false,null,null,"onClick=\"javascript:showProcedimientoList(3)\"","Agregar Procedimiento")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%">Orden</td>
							<td width="5%">Cant</td>
							<td width="5%">Frec</td>
							<td width="5%">Vol</td>
							<td width="5%">Mot</td>
							<td width="5%">Label Prior.</td>							
						</tr>

<%
al = CmnMgr.reverseRecords(iProce);
for (int i=1; i<=iProce.size(); i++) {
	key = al.get(i - 1).toString();
	CommonDataObject cdo = (CommonDataObject) iProce.get(key);
	String display = "";
	if (cdo.getAction() != null && cdo.getAction().equalsIgnoreCase("D")) display = " style=\"display:none\"";
%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("iAction"+i,cdo.getAction())%>
						<%=fb.hidden("codProcedimiento"+i,cdo.getColValue("codProcedimiento"))%>
						<%=fb.hidden("procedimientoDesc"+i,cdo.getColValue("procedimientoDesc"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01"<%=display%>>
							<td><%=cdo.getColValue("codProcedimiento")%></td>
							<td><%=cdo.getColValue("procedimientoDesc")%></td>
							<td align="center"><%=fb.decPlusZeroBox("precio"+i,cdo.getColValue("precio"),true,false,false,8,6.2,null,null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"")%></td>
							<td align="center"><%=fb.decBox("costo"+i,cdo.getColValue("costo"),false,false,false,8,6.2,null,null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"")%></td>
							<td align="center"> 
							<%=fb.intBox("display_order"+i,cdo.getColValue("display_order"),false,false,false,3,3,null,null,null)%></td>
							<td align="center"><%=fb.select("display_qty"+i,"N=NA=NO APLICA,O=OPC=OPCIONAL,R=REQ=REQUERIDO",cdo.getColValue("display_qty"),false,false,false,0,"Text10",null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"",null,"")%></td>
							<td align="center"><%=fb.select("display_freq"+i,"N=NA=NO APLICA,O=OPC=OPCIONAL,R=REQ=REQUERIDO",cdo.getColValue("display_freq"),false,false,false,0,"Text10",null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"",null,null)%></td>
							<td align="center"><%=fb.select("display_vol"+i,"N=NA=NO APLICA,O=OPC=OPCIONAL,R=REQ=REQUERIDO",cdo.getColValue("display_vol"),false,false,false,0,"Text10",null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"",null,null)%></td>
							<td align="center"><%=fb.select("display_rsn"+i,"N=NA=NO APLICA,O=OPC=OPCIONAL,R=REQ=REQUERIDO",cdo.getColValue("display_rsn"),false,false,false,0,"Text10",null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"",null,null)%></td>
							<td align="center"><%=fb.select("display_prior"+i,"N=NO,S=SI",cdo.getColValue("display_prior"),false,false,false,0,"Text10",null,"onChange=\"javascript:updAction(this.form.name,"+i+");\"",null,null)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<% } %>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
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

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tServSize",""+iTServ.size())%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userSize",""+iUser.size())%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamSize",""+iPam.size())%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("iProceSize",""+iProce.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("iDocSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel50">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(51)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Documentos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51" style="display:none">+</label><label id="minus51">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel51">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel>id</cellbytelabel></td>
							<td width="40%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="5%"><cellbytelabel>Estado</cellbytelabel></td>
							<td width="5%"><%=fb.button("addDocumento","+",true,false,null,null,"onClick=\"javascript:showDocumentosList(4)\"","Agregar Documento")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iDoc);
for (int i=1; i<=iDoc.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo = (CommonDataObject) iDoc.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
						<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
						<%=fb.hidden("name"+i,cdo.getColValue("name"))%>
						<%=fb.hidden("desc"+i,cdo.getColValue("description"))%>
						<tr class="TextRow01">
							<td align="center"><%=cdo.getColValue("id")%></td>
							<td><%=cdo.getColValue("name")%></td>
							<td><%=cdo.getColValue("description")%></td>
							<td align="center"><%=(cdo.getColValue("status").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");

%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
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

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tServSize",""+iTServ.size())%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userSize",""+iUser.size())%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamSize",""+iPam.size())%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("iProceSize",""+iProce.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("iDocSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Almacenes</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel61">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2">Com<cellbytelabel>pa&ntilde;&iacute;a</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
							<td width="35%" rowspan="2"><cellbytelabel>Comentarios</cellbytelabel></td>
							<td width="2%" rowspan="2"><cellbytelabel>BM</cellbytelabel></td>
							<td width="3%" rowspan="2"><%=fb.button("addWh","+",true,false,null,null,"onClick=\"javascript:showAlmacenList(5)\"","Agregar Almacenes")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iWH);
for (int i=1; i<=iWH.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo = (CommonDataObject) iWH.get(key);
%>
						<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
						<%=fb.hidden("compania_name"+i,cdo.getColValue("compania_name"))%>
						<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
						<%=fb.hidden("desc_almacen"+i,cdo.getColValue("desc_almacen"))%>

						<tr class="TextRow01">
							<td><%=cdo.getColValue("compania")%></td>
							<td><%=cdo.getColValue("compania_name")%></td>
							<td><%=cdo.getColValue("codigo_almacen")%></td>
							<td><%=cdo.getColValue("desc_almacen")%></td>
							<td><%=fb.textarea("comments"+i,cdo.getColValue("comments"),false,false,false,50,2,2000)%></td>
							<td align="center"><%=fb.checkbox("is_bm"+i,"Y",(cdo.getColValue("is_bm") != null && cdo.getColValue("is_bm").equalsIgnoreCase("Y")),false,null,null,"onClick=\"javascript:checkOne(this.form.name,'is_bm',"+iWH.size()+",this,1)\"")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");

%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div><!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tServSize",""+iTServ.size())%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userSize",""+iUser.size())%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmSize",""+iTAdm.size())%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamSize",""+iPam.size())%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("iProceSize",""+iProce.size())%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("iDocSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("iWHSize",""+iWH.size())%>
<%=fb.hidden("iProdCdsSize",""+iProdCds.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel70">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="35%"><%=cds.getColValue("descripcion")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(71)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>PRODUCTOS POR CENTRO</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus71" style="display:none">+</label><label id="minus71">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel71">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="20%"><cellbytelabel>Tipo Serv.</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="5%"><cellbytelabel>Cpt</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Incremento</cellbytelabel></td>
							<td width="5%"><cellbytelabel>Precio</cellbytelabel></td>
							<td width="5%"><cellbytelabel>Costo</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Und. Medida</cellbytelabel></td>
							<td width="3%"><%=fb.submit("addProd","+",false,false)%><%//=fb.submit("addProd","+",true,false,"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Producto")%></td>
						</tr>
<%System.out.println("iProdCds.size()==========="+ iProdCds.size());
al = CmnMgr.reverseRecords(iProdCds);
for (int i=0; i<iProdCds.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) iProdCds.get(key);
	String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";


%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("codigo_producto_axa"+i,cdo.getColValue("codigo_producto_axa"))%>
						<%=fb.hidden("origen_codigo"+i,cdo.getColValue("origen_codigo"))%>
						<%=fb.hidden("cod_internacional"+i,cdo.getColValue("cod_internacional"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
						<%=fb.hidden("codigoReg"+i,cdo.getColValue("codigoReg"))%>
						<tr class="TextRow01" align="center" <%=style%>>
							<td><%=cdo.getColValue("codigoReg")%></td>
							<td><%=fb.select("tser"+i,alTs,cdo.getColValue("tser"),false,false,0,"Text10",null,null,null,"")%></td>
							<td><%=fb.textarea("descripcion"+i,cdo.getColValue("descripcion"),true,false,false,30,2,2000)%></td>
							<td><%=fb.textBox("cpt"+i,cdo.getColValue("cpt"),false,false,false,15,20,"Text10",null,"")%></td>
							<td><%=fb.select("estatus"+i,"A=ACTIVO,I=INACTIO",cdo.getColValue("estatus"), false, false,0,"text10")%></td>
							<td><%=fb.select("incremento"+i,"N=NO,S=SI",cdo.getColValue("incremento"), false, false,0,"text10")%></td>
							<td><%=fb.decBox("precio"+i,cdo.getColValue("precio"),true,false,false,15,10.2,"Text10","","")%></td>
							<td><%=fb.decBox("costo"+i,cdo.getColValue("costo"),false,false,false,15,10.2,"Text10","","")%></td>
							<td><%=fb.select("um_cod_medida"+i,alUm,cdo.getColValue("um_cod_medida"),false,false,0,"Text10",null,null,null,"")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");

%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Tipo de Servicio'";
//S=Si el centro de servicio maneja admisiones
if (cds.getColValue("si_no").equalsIgnoreCase("S")) tabLabel += ",'Usuarios','Tipo de Admisión'";
else if(!tab.equals("0")) tab = ""+(Integer.parseInt(tab)-2);
tabLabel += ",'Procedimientos','Documentos','Almacenes','Productos'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

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
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";
	if (tab.equals("0")) //Tipo de Servicio
	{
		int size = 0;
		if (request.getParameter("tServSize") != null) size = Integer.parseInt(request.getParameter("tServSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_servicios_x_centros");
			cdo.setWhereClause("centro_servicio="+id+"");
			cdo.addColValue("tipo_servicio",request.getParameter("tipoServicio"+i));
			cdo.addColValue("centro_servicio",id);

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("tipoServicio",request.getParameter("tipoServicio"+i));
			cdo.addColValue("tipoServicioDesc",request.getParameter("tipoServicioDesc"+i));
			cdo.addColValue("visible_centro",(request.getParameter("visibleCentro"+i) != null && request.getParameter("visibleCentro"+i).equalsIgnoreCase("S"))?"S":"N");
			cdo.addColValue("visibleCentro",cdo.getColValue("visible_centro"));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");

			else
			{
				try
				{
					iTServ.put(cdo.getColValue("key"),cdo);
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
			vTServ.remove(((CommonDataObject) iTServ.get(itemRemoved)).getColValue("tipoServicio"));
			iTServ.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_servicios_x_centros");
			cdo.setWhereClause("centro_servicio="+id+"");

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("1")) //Usuario
	{
		int size = 0;
		if (request.getParameter("userSize") != null) size = Integer.parseInt(request.getParameter("userSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_cds");
			cdo.setWhereClause("cds="+id+"");
			cdo.addColValue("cds",id);
			cdo.addColValue("user_id",request.getParameter("user_id"+i));
			cdo.addColValue("user_name",request.getParameter("user_name"+i));
			cdo.addColValue("name",request.getParameter("name"+i));
			cdo.addColValue("comments",request.getParameter("comments"+i));
			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iUser.put(cdo.getColValue("key"),cdo);
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
			vUser.remove(((CommonDataObject) iUser.get(itemRemoved)).getColValue("user_id"));
			iUser.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo +"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_user_cds");
			cdo.addColValue("cds",id);

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2")) //Tipo de Admision
	{
		int size = 0;
		if (request.getParameter("tAdmSize") != null) size = Integer.parseInt(request.getParameter("tAdmSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_tipo_admision_x_cds");
			cdo.setWhereClause("cod_centro="+id+"");
			cdo.addColValue("cod_centro",id);
			cdo.addColValue("cod_categoria",request.getParameter("codCategoria"+i));
			cdo.addColValue("cod_tipo",request.getParameter("codTipo"+i));
			cdo.addColValue("cds_atencion",request.getParameter("cdsAtencion"+i));
			cdo.addColValue("estado_ini_atencion",request.getParameter("estadoIniAtencion"+i));

			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("codCategoria",request.getParameter("codCategoria"+i));
			cdo.addColValue("categoriaDesc",request.getParameter("categoriaDesc"+i));
			cdo.addColValue("codTipo",request.getParameter("codTipo"+i));
			cdo.addColValue("tipoAdmisionDesc",request.getParameter("tipoAdmisionDesc"+i));
			cdo.addColValue("cdsAtencion",request.getParameter("cdsAtencion"+i));
			cdo.addColValue("estadoIniAtencion",request.getParameter("estadoIniAtencion"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iTAdm.put(cdo.getColValue("key"),cdo);
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
			vTAdm.remove(((CommonDataObject) iTAdm.get(itemRemoved)).getColValue("codCategoria")+"-"+((CommonDataObject) iTAdm.get(itemRemoved)).getColValue("codTipo"));
			iTAdm.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_tipo_admision_x_cds");
			cdo.setWhereClause("cod_centro="+id+"");

			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	//------------------------------- productos pamd-----------------------------------
	/*
	else if (tab.equals("3"))
	{
		int size = 0;
		if (request.getParameter("pamSize") != null)
		size = Integer.parseInt(request.getParameter("pamSize"));
		String itemRemoved = "";
		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("TBL_PAMD_PRODUCTOS");
			cdo.setWhereClause("COD_CENTRO_SERVICIO="+id+"");
			if(request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i)=="")
			{
				cdo.setAutoIncCol("codigo");
				cdo.setAutoIncWhereClause("cod_centro_servicio="+id);
			}else
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("referencia",request.getParameter("referencia"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("precio",request.getParameter("precio"+i));//
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("COD_CENTRO_SERVICIO",id);//
			cdo.addColValue("key",request.getParameter("key"+i));
			key=request.getParameter("key"+i);

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
			 try
				{
					al.add(cdo);
					iPam.put(key,cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if(!itemRemoved.equals(""))
		{
			iPam.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if(baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("codigo","0");
			pamLastLineNo++;
			if (pamLastLineNo < 10) key = "00" + pamLastLineNo;
			else if (pamLastLineNo < 100) key = "0" + pamLastLineNo;
			else key = "" + pamLastLineNo;
			iPam.put(key,cdo);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("TBL_PAMD_PRODUCTOS");
			cdo.setWhereClause("COD_CENTRO_SERVICIO="+id+"");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
}*/
	else if (tab.equals("3")) {//Procedimiento

		int size = 0;
		if (request.getParameter("iProceSize") != null) size = Integer.parseInt(request.getParameter("iProceSize"));
		String itemRemoved = "";

		al.clear();
		iProce.clear();
		for (int i=1; i<=size; i++) {
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cds_procedimiento_x_cds");
			cdo.setWhereClause("cod_centro_servicio = "+id+" and cod_procedimiento = '"+IBIZEscapeChars.forSingleQuots(request.getParameter("codProcedimiento"+i))+"'");
			cdo.addColValue("cod_centro_servicio",id);

			cdo.setKey(i);
			cdo.addColValue("precio",request.getParameter("precio"+i));
			cdo.addColValue("costo",request.getParameter("costo"+i));
			cdo.addColValue("cod_procedimiento",request.getParameter("codProcedimiento"+i));
			cdo.addColValue("codProcedimiento",request.getParameter("codProcedimiento"+i));
			cdo.addColValue("procedimientoDesc",request.getParameter("procedimientoDesc"+i));
			
//throw new Exception("  display_qty == "+request.getParameter("display_qty"+i));

			cdo.addColValue("display_order",request.getParameter("display_order"+i));
			cdo.addColValue("display_qty",request.getParameter("display_qty"+i));
			cdo.addColValue("display_freq",request.getParameter("display_freq"+i));
			cdo.addColValue("display_vol",request.getParameter("display_vol"+i));
			cdo.addColValue("display_rsn",request.getParameter("display_rsn"+i));
			cdo.addColValue("display_prior",request.getParameter("display_prior"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {

				itemRemoved = request.getParameter("codProcedimiento"+i);
				if (request.getParameter("iAction"+i).equalsIgnoreCase("I")) cdo.setAction("X");
				else cdo.setAction("D");
				vProce.remove(itemRemoved);

			} else cdo.setAction(request.getParameter("iAction"+i));

			if (!cdo.getAction().equalsIgnoreCase("X")) {

				try {
					iProce.put(cdo.getKey(),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}

			}

		}

		if (!itemRemoved.equals("")) {

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;

		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);

	//***************************************************************************
	} else if (tab.equals("4")) {//Documentos

		int size = 0;
		if (request.getParameter("iDocSize") != null) size = Integer.parseInt(request.getParameter("iDocSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_exp_docs_cds");
			cdo.setWhereClause("cds_code="+id);
			cdo.addColValue("cds_code",id);
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("id",request.getParameter("id"+i));
			cdo.addColValue("doc_id",request.getParameter("id"+i));
			cdo.addColValue("name",request.getParameter("name"+i));
			cdo.addColValue("description",request.getParameter("desc"+i));
			cdo.addColValue("status",request.getParameter("status"+i));
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iDoc.put(cdo.getColValue("key"),cdo);
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
			vDoc.remove(((CommonDataObject) iDoc.get(itemRemoved)).getColValue("id"));
					iDoc.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_exp_docs_cds");
			cdo.setWhereClause("cds_code="+id);

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("5")) //Almacenes
	{
		int size = 0;
		if (request.getParameter("iWHSize") != null) size = Integer.parseInt(request.getParameter("iWHSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_cds_almacen");
			cdo.setWhereClause("cds= "+id);

			cdo.addColValue("compania",request.getParameter("compania"+i));
			cdo.addColValue("cds",id);
			cdo.addColValue("codigo_almacen",request.getParameter("codigo_almacen"+i));
			cdo.addColValue("almacen",request.getParameter("codigo_almacen"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("compania_name",request.getParameter("compania_name"+i));
			cdo.addColValue("desc_almacen",request.getParameter("desc_almacen"+i));
			cdo.addColValue("comments",request.getParameter("comments"+i));
			cdo.addColValue("is_bm",(request.getParameter("is_bm"+i) != null && request.getParameter("is_bm"+i).equalsIgnoreCase("Y"))?"Y":"N");

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iWH.put(cdo.getColValue("key"),cdo);
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
			vWH.remove(((CommonDataObject) iWH.get(itemRemoved)).getColValue("compania")+"-"+((CommonDataObject) iWH.get(itemRemoved)).getColValue("codigo_almacen"));
			iWH.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=5&tab=5&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_cds_almacen");
			cdo.setWhereClause("cds="+id);

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
		ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("6")) //Productos
	{
	int keySize =0;
	if (request.getParameter("iProdCdsSize") != null) keySize = Integer.parseInt(request.getParameter("iProdCdsSize"));
	iProdCds.clear();
	al.clear();
	String itemRemoved = "";
	//vDesc.clear();
for(int a=0; a<keySize; a++)
{
	CommonDataObject cdo1 = new CommonDataObject();

	cdo1.setTableName("tbl_cds_producto_x_cds");
	cdo1.setWhereClause("cod_centro_servicio="+id+" and codigo="+request.getParameter("codigo"+a));

	cdo1.addColValue("cod_centro_servicio",id);
	cdo1.addColValue("um_cod_medida",request.getParameter("um_cod_medida"+a));

	cdo1.addColValue("fecha_modificacion",cDateTime);
	cdo1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo1.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));
	cdo1.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));
	cdo1.addColValue("descripcion",request.getParameter("descripcion"+a));

	cdo1.addColValue("precio",request.getParameter("precio"+a));
	cdo1.addColValue("tser",request.getParameter("tser"+a));
	cdo1.addColValue("cpt",request.getParameter("cpt"+a));
	cdo1.addColValue("estatus",request.getParameter("estatus"+a));
	cdo1.addColValue("costo",request.getParameter("costo"+a));
	cdo1.addColValue("incremento",request.getParameter("incremento"+a));
	cdo1.addColValue("cod_internacional", request.getParameter("cod_internacional"+a));
	cdo1.addColValue("codigo_producto_axa", request.getParameter("codigo_producto_axa"+a));
	cdo1.addColValue("origen_codigo", request.getParameter("origen_codigo"+a));
	cdo1.addColValue("codigoReg", request.getParameter("codigoReg"+a));

	cdo1.setKey(a);
	cdo1.setAction(request.getParameter("action"+a));

	if(request.getParameter("codigo"+a) == null || request.getParameter("codigo"+a).trim().equals("")|| request.getParameter("codigo"+a).trim().equals("0")|| request.getParameter("codigo"+a).trim().equals("null"))
	{
		cdo1.setAutoIncWhereClause("cod_centro_servicio="+id);
	cdo1.setAutoIncCol("codigo");
	}
	else cdo1.addColValue("codigo", request.getParameter("codigo"+a));

		if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = cdo1.getColValue("codigoReg");
		if (cdo1.getAction().equalsIgnoreCase("I")) cdo1.setAction("X");//if it is not in DB then remove it
		else cdo1.setAction("D");
	}

	if (!cdo1.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iProdCds.put(cdo1.getKey(),cdo1);
			//vDesc.add(cdo1.getColValue("cod_acreedor")+"-"+cdo1.getColValue("cod_grupo"));
			al.add(cdo1);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

 }//End For

	if(!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=6&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
	return;
	}
if(request.getParameter("addProd")!=null)
{
CommonDataObject cdo1 = new CommonDataObject();
cdo1.addColValue("codigo","0");
cdo1.addColValue("codigoReg","0");
cdo1.addColValue("fecha_creacion",cDateTime);
cdo1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
cdo1.setAction("I");
cdo1.setKey(iProdCds.size() + 1);

iProdCds.put(cdo1.getKey(),cdo1);

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=6&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&whLastLineNo="+whLastLineNo);
 return;

}

if(al.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_cds_producto_x_cds");
cdo1.setWhereClause("cod_centro_servicio="+id);
cdo1.setKey(iProdCds.size() + 1);
cdo1.setAction("I");
al.add(cdo1);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(al,true);
ConMgr.clearAppCtx(null);

}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
//	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/centro_servicio_list.jsp"))
//	{
%>
//	window.opener.location = '<%//=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/centro_servicio_list.jsp")%>';
<%
//	}
//	else
//	{
%>
//	window.opener.location = '<%//=request.getContextPath()%>/admin/centro_servicio_list.jsp';
<%
//	}

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
}
%>