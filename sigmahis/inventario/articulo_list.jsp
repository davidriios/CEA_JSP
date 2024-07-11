<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="ItemMgr" scope="page" class="issi.inventory.ItemMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ItemMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
int iconHeight = 40;
int iconWidth = 40;
String sql = "";
String appendFilter = "";
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String fg = request.getParameter("fg");
String __tp_cod_ ="N";
if (fg == null)fg="INV";

if (familyCode == null)
{
	familyCode = "";
	classCode = "";
}
if (!familyCode.trim().equals(""))
{
	appendFilter += " and a.cod_flia="+familyCode;

	if (classCode == null) classCode = "";
	if (!classCode.equals("")) appendFilter += " and a.cod_clase="+classCode;
}
if (estado == null) estado = "";
if (!estado.trim().equals("")) appendFilter += " and upper(a.estado)='"+estado+"'";
if (consignacion == null) consignacion = "";
if (!consignacion.trim().equals("")) appendFilter += " and upper(a.consignacion_sino)='"+consignacion+"'";
if (venta == null) venta = "";
if (!venta.trim().equals("")) appendFilter += " and upper(a.venta_sino)='"+venta+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
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

	String codigo  = "";
	String descrip = "";
	String subclase ="";
	String barcode = "",itbm="";
	String fDate="",tDate="",afectaMayor="", tipo = "";
	if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
	{
		appendFilter += " and upper(a.cod_articulo) like '%"+request.getParameter("code").toUpperCase()+"%'";
	codigo     = request.getParameter("code");
	}
	if (request.getParameter("name") != null && !request.getParameter("name").equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
	descrip    = request.getParameter("name");
	}
	if (request.getParameter("barcode") != null && !request.getParameter("barcode").equals(""))
	{
		barcode = request.getParameter("barcode");
		if (crypt) {
			try{barcode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		appendFilter += " and tipo !='A' and a.cod_barra = '"+IBIZEscapeChars.forSingleQuots(barcode).trim()+"'";
		barcode = "";
	}
	if (request.getParameter("subclase") != null && !request.getParameter("subclase").equals(""))
	{
		appendFilter += " and a.cod_subclase like '%"+request.getParameter("subclase").toUpperCase()+"%'";
	subclase    = request.getParameter("subclase"); // utilizada para mantener la Descripci�n del Art�culo
	}
	if (request.getParameter("itbm") != null && !request.getParameter("itbm").equals(""))
	{
		appendFilter += " and upper(a.itbm) ='"+request.getParameter("itbm").toUpperCase()+"'";
		itbm    = request.getParameter("itbm");
	}
	if(!fg.trim().equals("FAR")){if(!fg.trim().equals("INV"))appendFilter += " and (a.fg ='"+fg+"' or nvl(get_sec_comp_param(a.compania,'INV_MOSTRAR_ART_INV'),'N')='S') ";

	if(fg.trim().equals("INV"))appendFilter +=" and replicado_far='N' and a.fg ='"+fg+"' ";}

	if(fg.trim().equals("FAR"))appendFilter +=" and replicado_far='S' ";

	if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_modif) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
		fDate = request.getParameter("fecha_desde");
	}
	if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_modif) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
		tDate = request.getParameter("fecha_hasta");
	}
	if (request.getParameter("afectaMayor") != null && !request.getParameter("afectaMayor").trim().equals(""))
	{
		appendFilter += " and a.fecha_afecta_conta is not null ";
		afectaMayor = request.getParameter("afectaMayor");
	}

	if (request.getParameter("tipo") != null && !request.getParameter("tipo").equals("")) {
		tipo = request.getParameter("tipo");
		appendFilter += " and a.tipo = '"+tipo+"'";
	}


	if(request.getParameter("familyCode") != null)
	{
//	sql="select a.product_id as productId,a.compania as companyCode, a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as description, b.nombre as familyName, c.descripcion as className ,nvl(a.consignacion_sino,'N')isAppropiation,nvl(a.venta_sino,'N') isSaleItem,nvl(a.estado,' ')status,d.subclase_id as subClassCode from tbl_inv_articulo a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c,tbl_inv_subclase d where a.compania=b.compania and a.cod_flia=b.cod_flia and a.compania=c.compania and a.cod_flia=c.cod_flia and a.cod_clase=c.cod_clase and a.cod_flia=d.cod_flia and a.cod_clase=d.cod_clase and a.cod_subclase=d.subclase_id and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.nombre, c.descripcion, a.descripcion";

sql="select a.product_id as productId,a.compania as companyCode, a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as description, b.nombre as familyName, c.descripcion as className ,nvl(a.consignacion_sino,'N')isAppropiation,nvl(a.venta_sino,'N') isSaleItem,nvl(a.estado,' ')status,a.cod_subclase as subClassCode,nvl(b.consignacion,'N') as other10 from tbl_inv_articulo a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c where a.compania=b.compania and a.cod_flia=b.cod_flia and a.compania=c.compania and a.cod_flia=c.cod_flia and a.cod_clase=c.cod_clase and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.nombre, c.descripcion, a.descripcion";


	System.out.println("SQL:="+sql);
	al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Item.class);

	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - Articulos - '+document.title;
function add(){
	const fg = '<%=fg%>';
	console.log(fg);
	if (fg == 'FAR'){
	abrir_ventana('../inventario/articulo_config.jsp?fg=<%=fg%>');
	}else{
		abrir_ventana('../inventario/articulo_config.jsp?fg=<%=fg%>');
	}
	
}
	
function edit(id,mode){
	const fg = '<%=fg%>';
	console.log(fg);
	if (fg == 'FAR'){
		abrir_ventana('../inventario/articulo_config.jsp?mode=view&id='+id+'&fg=<%=fg%>');
	}else{
	 abrir_ventana('../inventario/articulo_config.jsp?mode='+mode+'&id='+id+'&fg=<%=fg%>');
	}
}
function editCostoProm(id){abrir_ventana('../inventario/editar_costo_promedio.jsp?mode=edit&id='+id);}
function editConsignacion(id){abrir_ventana('../inventario/editar_consignacion.jsp?mode=edit&id='+id);}
function printList(){abrir_ventana('../inventario/print_list_articulos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');}
function updateBC(){abrir_ventana("../inventario/reg_cod_barra_x_lote.jsp");}
function regalia(id){showPopWin('../process/inv_upd_art_regalia.jsp?id='+id,winWidth*.65,_contentHeight*.75,null,null,'');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();document.search00.barcode.focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function showLoteFechaVenve(id, wh){
	showPopWin('../process/inv_view_inf_art.jsp?almacen='+wh+'&codigo='+id,winWidth*.75,winHeight*.65,null,null,'');
}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Nuevo Articulo';break;
		case 1:msg='Editar Articulo';break;
		case 2:msg='Ver Articulo';break;
		case 3:msg='Actualizar Codigo de Barra';break;
		case 4:msg='Actualizar costo Promedio';break;
		case 5:msg='Actualizar Consignacion';break;
		case 6:msg='Actualizar Precio de Regalia';break;
		//case 7:msg='Imprimir Lista';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0)add();
	else if(option==3)updateBC();
	else{
	if(option==undefined)alert('La opci�n no est� definida todav�a.\nPor favor consulte con su Administrador!');
	else
	{
		var k=document.form0.index.value;
		if(k=='')alert('Por favor seleccione un articulo antes de ejecutar una acci�n!');
			else
			{
				var compania = '<%=(String)session.getAttribute("_companyId")%>';
				var id = eval('document.form0.id'+k).value;
				var consig = eval('document.form0.consignacion'+k).value;
				var estado = eval('document.form0.estado'+k).value;

				if(option==1)edit(id,'edit');
				else if(option==2)edit(id,'view');
				else if(option==4){editCostoProm(id)}
				else if(option==5){
				var fliaConsig = eval('document.form0.fliaConsig'+k).value;
				var mov =  getDBData('<%=request.getContextPath()%>','nvl(sum(saldo_inicial)+sum(qty_in)-sum(qty_out)+sum(qty_aju),0) as mov ','vw_inv_mov_item',' compania='+compania+' and cod_articulo='+id,'');

				var msg ='';


				if(fliaConsig=='N'&&consig=='N'){msg+='El articulo no pertenece a la familia de Consignacion. Debe actualizar la Familia!!!!';}
				if(msg==''){if(mov!='0'){msg ='El articulo tiene transacciones registradas en la configuracion Actual!!!';}
				CBMSG.confirm(msg + " Desea Continuar con el proceso?",
										 {  btnTxt: 'Si,No',
													cb: function(r)
													{
														if(r=='Si')
														{
														 editConsignacion(id);
														}
													}
											}
										 );
					} else CBMSG.alert(msg);
				}
				else if(option==6){regalia(id)}

			 }
			}
	}
}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search00"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="name,test"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input c�digo barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el c�digo de barra,No encontramos en el DOM el campo de texto"></jsp:param>
		<jsp:param name="substrType" value="01"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1" id="_tblMain">
	 <tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/edit.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/search.gif"></a></authtype>

		<authtype type='52'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/Refresh_BarCod.png"></a></authtype>

		<authtype type='51'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/refresh.png"></a></authtype>

		<authtype type='53'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/cambio_de_estado_admision.png"></a></authtype>

		<authtype type='54'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/gift.png"></a></authtype>

		</td>
	</tr>
	<tr>
		<td>
 <table width="100%" cellpadding="1" cellspacing="0">

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("__tp_cod_",__tp_cod_)%>
<tr class="TextFilter">
	<td colspan="2">
		Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');
		</script>

		Tipo
		<%=fb.select("tipo","N=Normal,A=Activo,K=Kit,B=Bandeja",tipo, false, false, 0, "T")%>
	</td>
</tr>
<tr class="TextFilter">
	<td colspan="2">
		Estado
		<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"T")%>
		Consignaci&oacute;n
		<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"T")%>
		Venta
		<%=fb.select("venta","S=SI,N=NO",venta,false,false,0,"T")%>
		ITBM
		<%=fb.select("itbm","S=SI,N=NO",itbm,false,false,0,"T")%>&nbsp;Cod Subclase
		<%=fb.textBox("subclase",subclase,false,false,false,30,null,null,null)%>
		</td>
</tr>

<tr class="TextFilter">
	<td colspan="2">
		C&oacute;digo
		<%=fb.textBox("code",codigo,false,false,false,15,null,null,null)%>
		Nombre
		<%=fb.textBox("name",descrip,false,false,false,30,null,null,null)%>
&nbsp;
			Modificacion:<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2"/>
						<jsp:param name="nameOfTBox1" value="fecha_desde"/>
						<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
						<jsp:param name="nameOfTBox2" value="fecha_hasta"/>
						<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
						<jsp:param name="fieldClass" value="Text10"/>
						<jsp:param name="buttonClass" value="Text10"/>
						<jsp:param name="clearOption" value="true"/>
						</jsp:include>
						Afecta Mayor:<%=fb.checkbox("afectaMayor","S",afectaMayor.equals("S"),false)%>
		<%=fb.submit("go","Ir")%>
		&nbsp;&nbsp; C&oacute;d Barra
		<%=fb.textBox("barcode",barcode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
 <tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("__tp_cod_",__tp_cod_)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("__tp_cod_",__tp_cod_)%>
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
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("index","")%>
<%=fb.hidden("__tp_cod_",__tp_cod_)%>

		<tr class="TextHeader" align="center">
			<td width="10%">C&oacute;digo</td>
			<td width="46%">Nombre</td>
			<td width="10%">Consignaci&oacute;n Si/No</td>
			<td width="10%">Venta Si/no</td>
			<td width="6%">Estado</td>
			<td width="4%">&nbsp;</td>
			<td width="9%">&nbsp;</td>
		</tr>
<%
String familyClass = "";
for (int i=0; i<al.size(); i++)
{
	Item item = (Item) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!familyClass.equalsIgnoreCase("["+item.getFamilyName()+"] "+item.getClassName()))
	{
%>
		<tr class="TextHeader01">
			<td colspan="7">[<%=item.getFamilyName()%>] <%=item.getClassName()%></td>
		</tr>
<%
	}
%>
	<%=fb.hidden("id"+i,item.getItemCode())%>
	<%=fb.hidden("consignacion"+i,item.getIsAppropiation())%>
	<%=fb.hidden("estado"+i,item.getStatus())%>
	<%=fb.hidden("fliaConsig"+i,item.getOther10())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=item.getItemCode()%></td>
			<td style="cursor:pointer" onDblClick="javascript:showLoteFechaVenve(<%=item.getItemCode()%>, null);"><%=item.getDescription()%></td>
			<td align="center"><%=item.getIsAppropiation()%></td>
			<td align="center"><%=item.getIsSaleItem()%></td>
			<td align="center"><%=item.getStatus()%></td>
			<td align="center">
				<!--<authtype type='4'><a href="javascript:edit(<%=item.getFamilyCode()%>,<%=item.getClassCode()%>,<%=item.getItemCode()%>,<%=item.getSubClassCode()%>,<%=item.getProductId()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>-->
			</td>
			<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
				<!--<authtype type='51'><a href="javascript:editCostoProm(<%=item.getItemCode()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Costo Prom.</a></authtype>
				<% if (item.getIsAppropiation().equalsIgnoreCase("S")) { %><authtype type='52'><a href="javascript:editConsignacion(<%=item.getItemCode()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">No Consig.</a></authtype><% } %>-->
			</td>
		</tr>
<%
	familyClass = "["+item.getFamilyName()+"] "+item.getClassName();
}
%>
	 <%=fb.formEnd(true)%>
		</table>
		</div>
	</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("__tp_cod_",__tp_cod_)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("__tp_cod_",__tp_cod_)%>
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
<%
}
%>
%>