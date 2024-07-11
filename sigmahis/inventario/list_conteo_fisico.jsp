<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Delivery"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String wh = request.getParameter("wh");
String fp = request.getParameter("fp");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String compania = (String)session.getAttribute("_companyId");
String userName = request.getParameter("userName")==null?(String)session.getAttribute("_userName"):request.getParameter("userName");
String anio = request.getParameter("anio")==null?"":request.getParameter("anio");
String code = request.getParameter("code")==null?"":request.getParameter("code");
String status = request.getParameter("status")==null?"":request.getParameter("status");
String searchByBCorArtCod = request.getParameter("search_by_bc_or_cod_art")==null?"":request.getParameter("search_by_bc_or_cod_art");
String bcOrCodArt = request.getParameter("bc_or_cod_art")==null?"":request.getParameter("bc_or_cod_art");


/*
====================================================================================
	fp
	CF  = REGISTRO CONTEO FISICO
	ACF = ACTUALIZACION DEL INVENTARIO SEGUN EL CONTEO FISICO
====================================================================================
*/
if(fp == null)fp="CF";

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null || wh.trim().equals(""))
{
	if (alWh.size() > 0)
	{
		wh = ((CommonDataObject) alWh.get(0)).getOptValueColumn();
		appendFilter += " and cf.almacen="+wh;
	}
	else wh = "";
}
else
{
	appendFilter += " and cf.almacen="+wh;
}
if(request.getMethod().equalsIgnoreCase("GET"))
{
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	if (!anio.trim().equals(""))
	{
	appendFilter += " and cf.anio= '"+anio+"'";
	searchOn = "cf.anio";
	searchVal = anio;
	searchType = "1";
	searchDisp ="Año";
	}
	if (!code.equals(""))
	{
		appendFilter += " and upper(cf.consecutivo) like '%"+code+"%'";
		searchOn = "i.cod_articulo";
		searchVal = code;
		searchType = "1";
		searchDisp = "Consecutivo";
	}
	if (!status.equals(""))
	{
		appendFilter += " and cf.estatus = '"+status+"'";
		searchOn = "cf.estatus";
		searchVal = status;
		searchType = "1";
		searchDisp = "Consecutivo";
	}

	 if (!userName.equals(""))
	{
		appendFilter += " and cf.usuario_creacion like '%"+userName+"%'";
		searchOn = "cf.usuario_creacion";
		searchVal = userName;
		searchType = "1";
		searchDisp = "Consecutivo";
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
	 if (searchType.equals("1"))
	 {
		 appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
	 }
	}
	else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
	}
	if(fp != null && fp.trim().equals("ACF"))
	appendFilter += " and cf.asiento_sino = 'N' and cf.estatus = 'P' ";

				StringBuffer sbSql = new StringBuffer();

		sbSql.append("select distinct (select count(*)  from  tbl_inv_conteo_fisico CF where cf.compania = cf.compania and cf.asiento_sino = 'N' and cf.estatus = 'P' and cf.almacen = cf.compania )conteo,cf.almacen, (select descripcion from tbl_inv_almacen where codigo_almacen = cf.almacen and compania = cf.compania) as desc_almacen, cf.anio, cf.codigo_anaquel anaquel, cf.consecutivo, to_char(cf.fecha_conteo,'dd/mm/yyyy')fecha_conteo, cf.observaciones, nvl(cf.asiento_sino,'N')asientoSino, cf.estatus,decode(cf.estatus,'C','NUEVA LISTA','P', 'PENDIENTE (POR ACTUALIZAR)','A' ,'ACTIVO (ULTIMO CONTEO ACTUALIZADO)','I','INACTIVO  (INV.ANTERIORES YA ACTUALIZADOS)','N','ANULADO (ANULAR INVENTARIO FISICO') descEstatus,decode(cf.codigo_anaquel ,-99,cf.nombre_anaquel,(select descripcion from tbl_inv_anaqueles_x_almacen where compania = cf.compania and codigo = cf.codigo_anaquel and codigo_almacen =cf.almacen)) descAnaquel, cf.usuario_creacion");

				if (!bcOrCodArt.equals(""))
						sbSql.append(", cfd.cantidad_contada, (select descripcion from tbl_inv_articulo where cod_articulo=cfd.cod_articulo and compania = cfd.compania) as art_desc") ;

				sbSql.append(" from tbl_inv_conteo_fisico cf");

				if (!bcOrCodArt.equals(""))
						sbSql.append(", tbl_inv_detalle_fisico cfd") ;

				sbSql.append(" where cf.compania = ");
				sbSql.append((String) session.getAttribute("_companyId"));
				sbSql.append(appendFilter);

				if (request.getParameter("bc_or_cod_art") != null && !request.getParameter("bc_or_cod_art").equals("")){
					bcOrCodArt = request.getParameter("bc_or_cod_art");
					if (crypt) {
						try{
							bcOrCodArt = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("bc_or_cod_art"),"_cUrl",256));
						}catch(Exception e){
							System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one uses the button. "+e);
						}
					}

					sbSql.append(" and cfd.cf1_anio = cf.anio and cfd.anaquel = cf.codigo_anaquel and cfd.almacen = cf.almacen and cfd.compania = cf.compania and cfd.cf1_consecutivo = cf.consecutivo");
					if (searchByBCorArtCod.equals("A")) {
						sbSql.append(" and cfd.cod_articulo = ");
						sbSql.append(bcOrCodArt);
					} else {
						sbSql.append(" and exists (select null from tbl_inv_articulo where cod_articulo = cfd.cod_articulo and compania = cfd.compania and cod_barra = '");
						sbSql.append(IBIZEscapeChars.forSingleQuots(bcOrCodArt).trim());
						sbSql.append("')");
					}
					bcOrCodArt = "";
				}

				sbSql.append(" order by 3, cf.anio desc, cf.consecutivo desc ");

	if (request.getParameter("beginSearch") !=null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
	}

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
<script language="javascript">
document.title = 'Inventario - Registros de Conteo  - '+document.title;

function printList()
{
	//print_list_consulta_articulo
	var wh = $("#wh").val();
	var anio = $("#anio").val() || 'ALL';
	var code = $("#code").val() || 'ALL';
	var status = $("#status").val() || 'ALL';
	var userName = $("#userName").val() || 'ALL';
	var searchByBCorArtCod = $("#search_by_bc_or_cod_art").val() || 'ALL';
	var bcOrCodArt = '<%=bcOrCodArt%>' || 'ALL';
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_list_conteo_fisico.rptdesign&wh='+wh+'&anio='+anio+'&code='+code+'&status='+status+'&userName='+userName+'&search_by_bc_or_cod_art='+searchByBCorArtCod+'&bc_or_cod_art='+bcOrCodArt+'&pCtrlHeader=false&fp=<%=fp%>');
}
function add()
{
	abrir_ventana('../inventario/reg_inventario_fisico.jsp');
}
function view(k)
{
	var x =0;
	var asiento1 ='';
	var size = document.form01.keySize.value;
	<%if(fp != null && fp.trim().equals("ACF")){%>
	for(i=0;i<size;i++)
	{
		 var asiento		  = eval('document.form01.asientoSino'+i).value;
		 var status		= eval('document.form01.estatus'+i).value;
		 if(asiento == "N" && status =="P") x++;
	}
	<%}%>
	var asiento = 	eval('document.form01.asientoSino'+k).value;
	var almacen = 	eval('document.form01.almacen'+k).value;
	var anaquel = 	eval('document.form01.anaquel'+k).value;
	var anio    = 	eval('document.form01.anio'+k).value;
	var id      = 	eval('document.form01.id'+k).value;
	var status  = 	eval('document.form01.estatus'+k).value;

	var mode ="";
	if(x>0)asiento1 ='N';
	else asiento1 ='S';
	abrir_ventana('../inventario/reg_inventario_fisico.jsp?mode=view&id='+id+'&anio='+anio+'&almacen='+almacen+'&anaquel='+anaquel+'&asiento='+asiento1+'&tr=<%=fp%>');
}
function edit(k)
{
	var x =0;
	var asiento1 ='';
	var size = document.form01.keySize.value;

	var asiento = 	eval('document.form01.asientoSino'+k).value;
	var almacen = 	eval('document.form01.almacen'+k).value;
	var anaquel = 	eval('document.form01.anaquel'+k).value;
	var anio    = 	eval('document.form01.anio'+k).value;
	var id      = 	eval('document.form01.id'+k).value;
	var status  = 	eval('document.form01.estatus'+k).value;
	var fechaConteo  = 	eval('document.form01.fecha_conteo'+k).value;

	var mode ="";
	if(x>0)asiento1 ='N';
	else asiento1 ='S';
	abrir_ventana('../inventario/reg_inventario_fisico.jsp?mode=edit&id='+id+'&anio='+anio+'&almacen='+almacen+'&anaquel='+anaquel+'&asiento='+asiento1+'&tr=<%=fp%>&fecha_diff_t='+fechaConteo);
}

function anular(k){
	var almacen = 	eval('document.form01.almacen'+k).value;
	var anio    = 	eval('document.form01.anio'+k).value;
	var id      = 	eval('document.form01.id'+k).value;

	top.CBMSG.confirm('Confirma que desea anular el conteo?',{
		btnTxt: "Si,No",
		cb:function(r){
			 if (r=="Si"){
			 var __exec = executeDB('<%=request.getContextPath()%>','call sp_inv_anula_conteo('+id+', '+anio+', '+almacen+',\'<%=(String) session.getAttribute("_userName")%>\')','tbl_inv_conteo_fisico');
			 if (__exec) {
				 top.CBMSG.alert('Conteo anulado Satisfactoriamente!',{
				 btnTxt:"Ok",
				 cb:function(rr){
					 if(rr=="Ok") window.location.reload(true);
				 }
			 });
			 } else top.CBMSG.error('No se pudo anular el Conteo!',{btnTxt:"Ok"});
		 }
		}
	});
}
function actualizar(k){
	var almacen  =  eval('document.form01.almacen'+k).value;
	var anio     = 	eval('document.form01.anio'+k).value;
	var id       = 	eval('document.form01.id'+k).value;
		var mes  	 = eval('document.form01.mes'+k).value;

	top.CBMSG.confirm('¿Esta usted seguro que desea actualizar el inventario de este almacén??',{
		btnTxt: "Si,No",
		cb:function(r){
			 if (r=="Si"){
				showPopWin('../common/run_process.jsp?fp=ACTCONTEO&actType=7&docType=ACTCONTEO&docId='+id+'&docNo='+id+'&almacen='+almacen+'&anio='+anio+'&mes='+mes+'&codigo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');
		 }
		 }
	});
}

function doReconteo(i,wh,anaquel,anio,consecutivo){
	if (!($("#recount").hasClass("processing")) ){
	 $("#recount").text("Procesando...");
	 $("#recount").addClass("processing");

	var __exec = executeDB('<%=request.getContextPath()%>',"call sp_inv_reconteo("+consecutivo+","+anio+","+wh+","+anaquel+",'<%=(String)session.getAttribute("_userName")%>')",'');

	if (__exec) window.location.reload();
	else {
			$("#recount").text("Reconteo");
			$("#recount").removeClass("processing");
			CBMSG.error("Error al tratar de cambiar el estado a NUEVO. Por favor contacte un administrador.");
		}
	}
}

<%if(!bcOrCodArt.equals("")){%>
$(function(){
	$(".counted").text($("#totContadad").val());
});
<%}%>
</script>
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="searchMain"></jsp:param>
	<jsp:param name="barcodeEl" value="bc_or_cod_art"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="name,"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
		<jsp:param name="substrType" value="01"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - TRANSACCIONES - REGISTRO DE CONTEO FISCO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right"><%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
if(fp != null && fp.trim().equals("CF"))
{
%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Conteo ]</a></authtype>
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
			<%
}
%>
			&nbsp; </td>
	</tr>
	<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
	<tr class="TextFilter">
		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("beginSearch","")%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fp",fp)%>
		<td>Almac&eacute;n
		<%=fb.select("wh",alWh,wh)%>
		Año&nbsp;<%=fb.textBox("anio",anio,false,false,false,4,null,null,null)%>
		C&oacute;digo&nbsp;<%=fb.textBox("code",code,false,false,false,4,null,null,null)%>
	&nbsp;&nbsp;&nbsp;
	Estado&nbsp;<%=fb.select("status","C=NUEVA LISTA,P=PENDIENTE (POR ACTUALIZAR),A=ACTIVO (ULTIMO CONTEO ACTUALIZADO),I=INACTIVO (INV.ANTERIORES YA ACTUALIZADOS),N=ANULADO (ANULAR INVENTARIO FISICO",status,false,false,0,"Text10","width:100px",null,null,"T")%>
	&nbsp;&nbsp;&nbsp;
	Usuario&nbsp;<%=fb.textBox("userName",userName,false,false,false,10,"ignore",null,null)%>
		&nbsp;&nbsp;&nbsp;
		<%=fb.select("search_by_bc_or_cod_art","C=CODIGO BARRA,A=CODIGO ART.",searchByBCorArtCod,false,false,0,"Text10","",null,null,"")%>
		<%=fb.textBox("bc_or_cod_art",bcOrCodArt,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
		&nbsp;&nbsp;&nbsp;
	<%=fb.submit("go","Ir")%> </td>
		<%=fb.formEnd()%> </tr>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
</table>
<!--<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
			&nbsp; </td>
	</tr>
</table> -->
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp" );%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("wh",wh)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("code",code)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("userName",userName)%>
					<%=fb.hidden("beginSearch","")%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("search_by_bc_or_cod_art",searchByBCorArtCod)%>
					<%=fb.hidden("bc_or_cod_art",bcOrCodArt)%>
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
					<%=fb.hidden("wh",wh)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("code",code)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("userName",userName)%>
					<%=fb.hidden("beginSearch","")%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
										<%=fb.hidden("search_by_bc_or_cod_art",searchByBCorArtCod)%>
					<%=fb.hidden("bc_or_cod_art",bcOrCodArt)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%> </tr>
			</table></td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder"><%fb = new FormBean("form01",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart()%>
			<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="3%">Año</td>
					<td width="4%">C&oacute;digo</td>
					<td width="7%">Fecha</td>
					<td width="15%">Anaquel</td>
					<%if (bcOrCodArt != null && !bcOrCodArt.trim().equals("")){%>
					<td width="20%">Estado</td>
					<td width="5%">Cantidad</td>
					<%}else{%>
					<td width="15%">Estado</td>
					<%}%>
			<td width="20%" align="center">Observaciones</td>
			<td width="8%" align="center">Creado por</td>
					<td width="17%" align="right">&nbsp;</td>
					<td width="12%" align="right">&nbsp;</td>
				</tr>
				<%
				String whName = "";
				int totContadad = 0;
				for (int i=0; i<al.size(); i++)
				{
					 CommonDataObject cdo = (CommonDataObject) al.get(i);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";

					if (!whName.equalsIgnoreCase(cdo.getColValue("desc_almacen")))
					{
				%>
				<tr class="TextHeader01">
					<td colspan="10"><%=cdo.getColValue("desc_almacen")%><%=!bcOrCodArt.equals("") && cdo.getColValue("art_desc") !=null && !cdo.getColValue("art_desc").equals("")?"   ("+cdo.getColValue("art_desc")+" // Cant. Tot.: ":""%><span class="counted"></span>)</td>
				</tr>
				<%
					}
				%>
				<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("asientoSino"+i,cdo.getColValue("asientoSino"))%>
		<%=fb.hidden("almacen"+i,cdo.getColValue("almacen"))%>
		<%=fb.hidden("anaquel"+i,cdo.getColValue("anaquel"))%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("consecutivo"))%>
		<%=fb.hidden("fecha_conteo"+i,cdo.getColValue("fecha_conteo"))%>
				<%if (!bcOrCodArt.trim().equals("")) {%>
				<%=fb.hidden("cantidad_contada"+i,cdo.getColValue("cantidad_contada","0"))%>
				<%}%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("anio")%></td>
					<td align="center"><%=cdo.getColValue("consecutivo")%></td>
					<td align="center"><%=cdo.getColValue("fecha_conteo")%></td>
					<td><%=cdo.getColValue("descAnaquel")%></td>


					<%if (request.getParameter("bc_or_cod_art").trim() != null && !request.getParameter("bc_or_cod_art").trim().equals("")){%>
					<td align="left"><%=cdo.getColValue("descEstatus")%></td>
					<td align="center"><%=cdo.getColValue("cantidad_contada")%></td>

					<%}else{%>
					<td align="left"><%=cdo.getColValue("descEstatus")%></td>
					<%}%>
					<td align="center"><%=cdo.getColValue("observaciones")%></td>
					<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
					<%if(fp != null && fp.trim().equals("CF")){%>
					<td align="center">
						<%if(cdo.getColValue("estatus") != null && (/*cdo.getColValue("estatus").trim().equals("P") || */ cdo.getColValue("estatus").trim().equals("C"))){%>
						<authtype type='4'>
						<a href="javascript:edit(<%=i%>)" class="Link00 LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Editar</a>
						</authtype>
						<%}%>
						<authtype type='1'>
						|&nbsp;<a href="javascript:view(<%=i%>)" class="Link00 LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a>
						|&nbsp;<a href="print_inventario_fisico.jsp?almacen=<%=cdo.getColValue("almacen")%>&anio=<%=cdo.getColValue("anio")%>&consecutivo=<%=cdo.getColValue("consecutivo")%>&estado=<%=cdo.getColValue("estatus")%>&anaquelx=<%=cdo.getColValue("anaquel")%>&anaquely=<%=cdo.getColValue("anaquel")%>" class="Link00 LinksTextwhite" title="Imprimir Detallado" target="_blank" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Imprimir</a>

			|&nbsp;<a href="print_inventario_fisico_values.jsp?almacen=<%=cdo.getColValue("almacen")%>&anio=<%=cdo.getColValue("anio")%>&consecutivo=<%=cdo.getColValue("consecutivo")%>&anaquelx=<%=cdo.getColValue("anaquel")%>&anaquely=<%=cdo.getColValue("anaquel")%>" class="Link00 LinksTextwhite" target="_blank" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')" title="Imprimir Valor de Inventario fisico Solo">Valores</a>

						</authtype>
					</td>
					<td align="center">&nbsp;
						<%if(cdo.getColValue("estatus") != null && cdo.getColValue("estatus").trim().equals("P")){%>
						<authtype type='7'>
				<a href="javascript:anular(<%=i%>)" class="Link00 LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Anular</a>
						</authtype>
			<authtype type='50'>
			<a href='javascript:doReconteo(<%=i%>,"<%=cdo.getColValue("almacen")%>","<%=cdo.getColValue("anaquel")%>",<%=cdo.getColValue("anio")%>,"<%=cdo.getColValue("consecutivo")%>")' id="recount" class="Link00 LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><span id="recount_txt">Reconteo</span></a>
						</authtype>
						<%}%>
					</td>
					<%}else if(fp != null && fp.trim().equals("ACF")){%>
					<td align="center" colspan="2">&nbsp;
						<authtype type='4'><font color="#FF0000" > CONTEO PARA EL  : MES:</font><br><%=fb.textBox("mes"+i,fecha.substring(3,5),true,false,false,12)%><a href="javascript:actualizar(<%=i%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Actualizar</a></authtype>
					</td>
					</td>
					<%}%>
				</tr>
				<%
					whName = cdo.getColValue("desc_almacen");
					if (!bcOrCodArt.trim().equals("")) {
						totContadad += Integer.parseInt(cdo.getColValue("cantidad_contada"));
					}
				}
				if(fp != null && fp.trim().equals("ACF")&& al.size() == 0)
				{
				%>
				<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
					<td align="center" colspan="10">NO HAY CONTEO PENDIENTE POR ACTUALIZAR EN ESTE ALMACEN</td>
				</tr>
				<%}%>
				<%=fb.hidden("keySize",""+al.size())%>
				<%if (!bcOrCodArt.trim().equals("")) {%>
				<%=fb.hidden("totContadad",""+totContadad)%>
				<%}%>
			</table>
			<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
			<%=fb.formEnd()%> </td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
		<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
		<%=fb.hidden("wh",wh)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("code",code)%>
		<%=fb.hidden("status",status)%>
		<%=fb.hidden("userName",userName)%>
		<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("search_by_bc_or_cod_art",searchByBCorArtCod)%>
		<%=fb.hidden("bc_or_cod_art",bcOrCodArt)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
			 <%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
		<%=fb.hidden("wh",wh)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("code",code)%>
		<%=fb.hidden("status",status)%>
		<%=fb.hidden("userName",userName)%>
		<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("search_by_bc_or_cod_art",searchByBCorArtCod)%>
		<%=fb.hidden("bc_or_cod_art",bcOrCodArt)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%> </tr>
			</table></td>
	</tr>
</table>
</body>
</html>
<%
}
%>