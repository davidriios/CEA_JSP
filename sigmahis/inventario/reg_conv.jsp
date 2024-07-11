
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Conversion"%>
<%@ page import="issi.inventory.ConvDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.Vector" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.inventory.ConversionMgr" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ConvMgr.setConnection(ConMgr);

Conversion Conv = new Conversion();
ConvDetails ConvDet = new ConvDetails();

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String almacen = request.getParameter("almacen");
boolean viewMode = false;

/*
INV250080		fg = DM = SOLICITUD DE DESCARTE DE MERCANCIA
INV250020		fg = ED = AJUSTES POR ERROR O DESCARTE
INV250050		fg = AI = SOLICITUD DE AJUSTE A INVENTARIO
INV250040		fg = ND = AJUSTES POR NOTA DE DEBITO
INV250070		fg = NE = AJUSTES A NOTAS DE ENTREGA
*/


if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		if (change == null)
		{
			Conv.setSecuencia("0");
			Conv.setFecha(CmnMgr.getCurrentDate("dd/mm/yyyy"));
			Conv.setCantidad("0");
			ConvDet.setCantidad("0");
		}
	}
	else
	{
			sql="select a.secuencia, a.compania, a.almacen, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.cod_familia codFamilia, a.cod_clase codClase, a.cod_articulo codArticulo, a.cantidad, b.descripcion articulo, al.descripcion descAlmacen from tbl_inv_coversion_encab a, tbl_inv_articulo b, tbl_inv_almacen al where a.cod_familia = b.cod_flia and a.cod_clase = b.cod_clase and a.cod_articulo = b.cod_articulo and a.cod_familia is not null and a.cod_clase is not null and a.cod_articulo is not null and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.secuencia= "+id+" and a.almacen = "+almacen+" and a.almacen = al.codigo_almacen and a.compania = al.compania";
			
			System.out.println("sql..= "+sql);
			Conv = (Conversion) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Conversion.class);
			if(Conv == null)
			Conv = new Conversion(); 
			
			sql="select a.secuencia, a.codigo_almacen codigoAlmacen, a.compania, a.art_cod_clase artCodClase , a.art_cod_flia artCodFlia, a.art_cod_articulo artCodArticulo,  a.cantidad, ar.descripcion articulo  from tbl_inv_conversion a,tbl_inv_articulo ar where  a.compania = "+(String) session.getAttribute("_companyId")+" and a.secuencia=  "+id+" and a.codigo_almacen = "+almacen+" and a.art_cod_clase = ar.cod_clase and a.art_cod_flia=ar.cod_flia and a.art_cod_articulo = ar.cod_articulo and a.compania = ar.compania";
			
			System.out.println("sql..= "+sql);
			ConvDet = (ConvDetails) sbb.getSingleRowBean(ConMgr.getConnection(), sql, ConvDetails.class);
			if(ConvDet == null)
			ConvDet = new ConvDetails(); 
			
			
			
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Entrega - "+document.title;
<%}%>
	function addItem(i){
		var codAlmacen = document.form1.codigoAlmacen.value;
		var codFlia = document.form1.cod_flia1.value;
		var codClase = document.form1.cod_clase1.value;
		var codArticulo = document.form1.cod_articulo1.value;
		if(codAlmacen=="")
		{
		 alert('Seleccione Almacen!');
		  buscaCA();
			return true;
		}
		else {
			if(i==2 && codFlia == '' && codClase == '' && codArticulo == '') alert('Seleccione Artículo de salida!');
			else abrir_ventana1('../inventario/sel_articles_conv.jsp?mode=<%=mode%>&fg=&fp='+i+'&codAlmacen='+codAlmacen+'&codFlia='+codFlia+'&codClase='+codClase+'&codArticulo='+codArticulo);
		}
	}
	function check()
	{
			var cantidad 				= parseInt(document.form1.cantidad1.value,10);
			if(cantidad =="0")
			{
				alert('La cantidad no puede ser igual a 0');
				return true;
			
			}
			else return false;
	}
	function doSubmit(baction){
	
		if(form1Validation())
		{			
			if(!check())
			{
				document.form1.baction.value = baction;
				document.form1.submit();
			}else form1BlockButtons(false);
		}
	}
	
	function adjustIFrameSize (iframeWindow){
		if (iframeWindow.document.height){
			var iframeElement = document.getElementById (iframeWindow.name);
			iframeElement.style.height = iframeWindow.document.height + 'px';
			iframeElement.style.width = iframeWindow.document.width + 'px';
		} else if (document.all) {
			var iframeElement = document.all[iframeWindow.name];
			if (iframeWindow.document.compatMode &&	iframeWindow.document.compatMode != 'BackCompat'){
				iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 'px';
			} else {
				iframeElement.style.height = iframeWindow.document.body.scrollHeight + 'px';
			}
		}
	}
	
	function buscaCA(){
		codAlmacen = document.form1.codigoAlmacen.value;
		abrir_ventana2('../inventario/sel_aju_almacen.jsp?fg=conv&codAlmacen='+codAlmacen);
	}
	
	function ver(){
		var cant_disponible	= parseInt(document.form1.cant_disponible1.value,10);
		var cantidad 				= parseInt(document.form1.cantidad1.value,10);
		if(cantidad > cant_disponible && document.form1.cod_articulo1.value != ''){
			alert('La cantidad supera la disponible!');
			document.form1.cantidad1.value = 0;
		} else {
			if(!isNaN(document.form1._cantidad2.value)){
				document.form1.cantidad2.value = parseInt(document.form1._cantidad2.value,10)*cantidad;
			}
		}
	}
	
	function clearFields(fg){
		if(fg=='1'){
			document.form1.cod_flia1.value 				= '';
			document.form1.cod_clase1.value 			= '';
			document.form1.cod_articulo1.value		= '';
			document.form1.articulo1.value 				= '';
			document.form1.cantidad1.value 				= '0';
			document.form1.cant_disponible1.value	= '0';
		}
		document.form1.cod_flia2.value 				= '';
		document.form1.cod_clase2.value 			= '';
		document.form1.cod_articulo2.value		= '';
		document.form1.articulo2.value 				= '';
		document.form1._cantidad2.value 			= '0';
		document.form1.cantidad2.value 				= '0';
		document.form1.cant_disponible2.value	= '0';
	}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - CONVERSION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
   <%    fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			  <%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("clearHT","")%>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">Conversion al Inventario</td>
        </tr>
        <tr class="TextRow01">
          <td>Almac&eacute;n</td>
          <td>
				<%	StringBuffer sbSql = new StringBuffer();
					sbSql.append("select codigo_almacen,codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = ");
					sbSql.append(session.getAttribute("_companyId"));
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and codigo_almacen in (");
						if(session.getAttribute("_almacen_inv")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_inv")));
						else sbSql.append("-2");
					sbSql.append(")");
				}
				
				sbSql.append(" order by codigo_almacen");
%>
					<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"codigoAlmacen",(Conv.getAlmacen()!=null && !Conv.getAlmacen().equals("")?Conv.getAlmacen():(SecMgr.getParValue(UserDet,"almacen_inv")!=null && !SecMgr.getParValue(UserDet,"almacen_inv").equals("")?SecMgr.getParValue(UserDet,"almacen_inv"):"")),false,false,0, "text10", "", "")%>
					
					
					<%//=fb.textBox("codigoAlmacen",Conv.getAlmacen(),true,false,true,5)%>
					<%//=fb.textBox("nombreAlmacen",Conv.getDescAlmacen(),false,false,true,40)%>
					<%//=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:buscaCA()\"")%>
					</td>
          <td width="15%" align="right">Fecha</td>
          <td width="35%"><%=fb.textBox("fecha",Conv.getFecha(),false,false,true,10)%></td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">Conversi&oacute;n</td>
        </tr>
				<tr class="TextHeader">
          <td colspan="4">Artìculo Saliente</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">
						<table width="100%" align="center">
							<tr class="TextHeader" align="center">
								<td colspan="3">C&oacute;digo</td>
								<td rowspan="2" width="36%">Descripci&oacute;n</td>
								<td rowspan="2" width="9%">Cantidad</td>
								<td rowspan="2" width="9%">&nbsp;</td>
							</tr>
							<tr class="TextHeader" align="center">
								<td width="5%">Familia</td>
								<td width="5%">Clase</td>
								<td width="10%">Art&iacute;culo</td>
							</tr>
							<%=fb.hidden("cant_disponible1",Conv.getCantidad())%>
							<tr class="TextRow01" align="center">
								<td><%=fb.intBox("cod_flia1",Conv.getCodFamilia(),true,false,true,10)%></td>
								<td><%=fb.intBox("cod_clase1",Conv.getCodClase(),true,false,true,10)%></td>
								<td><%=fb.intBox("cod_articulo1",Conv.getCodArticulo(),true,false,true,10)%></td>
								<td><%=fb.textBox("articulo1",Conv.getArticulo(),false,false,true,50)%></td>
								<td><%=fb.intBox("cantidad1",Conv.getCantidad(),true,false,viewMode,5,null,null,"onChange=\"javascript:ver(1)\"")%></td>
								<td align="center"><%=fb.button("addItem1","...",false,viewMode,"","","onClick=\"javascript:addItem(1)\"")%></td>
							</tr>
						</table>
					</td>
        </tr>
				<tr class="TextHeader">
          <td colspan="4">Artìculo Entrante</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">
						<table width="100%" align="center">
							<tr class="TextHeader" align="center">
								<td colspan="3">C&oacute;digo</td>
								<td rowspan="2" width="36%">Descripci&oacute;n</td>
								<td rowspan="2" width="9%">Cantidad</td>
								<td rowspan="2" width="9%">&nbsp;</td>
							</tr>
							<tr class="TextHeader" align="center">
								<td width="5%">Familia</td>
								<td width="5%">Clase</td>
								<td width="10%">Art&iacute;culo</td>
							</tr>
							<%=fb.hidden("cant_disponible2","0")%>
							<%=fb.hidden("_cantidad2","0")%>
							<tr class="TextRow01" align="center">
								<td><%=fb.intBox("cod_flia2",ConvDet.getArtCodFlia(),true,false,true,10)%></td>
								<td><%=fb.intBox("cod_clase2",ConvDet.getArtCodClase(),true,false,true,10)%></td>
								<td><%=fb.intBox("cod_articulo2",ConvDet.getArtCodArticulo(),true,false,true,10)%></td>
								<td><%=fb.textBox("articulo2",ConvDet.getArticulo(),false,false,true,50)%></td>
								<td><%=fb.intBox("cantidad2",ConvDet.getCantidad(),false,false,true,5,null,null,"")%></td>
								<td align="center"><%=fb.button("addItem2","...",false,viewMode,"","","onClick=\"javascript:addItem(2)\"")%></td>
							</tr>
						</table>
					</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4" align="right">Opciones de Guardar:<%=fb.radio("saveOption","N")%>Crear Otro
            <!--<%=fb.radio("saveOption","O")%>Mantener Abierto -->
            <%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>

        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
	String errCode = "";
	String errMsg = "";

	Conv.setCompania((String) session.getAttribute("_companyId"));
	Conv.setUser((String) session.getAttribute("_userName"));

	Conv.setAlmacen(request.getParameter("codigoAlmacen"));

	Conv.setCodFamilia(request.getParameter("cod_flia1"));
	Conv.setCodClase(request.getParameter("cod_clase1"));
	Conv.setCodArticulo(request.getParameter("cod_articulo1"));
	Conv.setCantidad(request.getParameter("cantidad1"));

	ConvDet.setArtCodFlia(request.getParameter("cod_flia2"));
	ConvDet.setArtCodClase(request.getParameter("cod_clase2"));
	ConvDet.setArtCodArticulo(request.getParameter("cod_articulo2"));
	ConvDet.setCantidad(request.getParameter("cantidad2"));
	
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConvMgr.addConv(Conv, ConvDet);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (ConvMgr.getErrCode().equals("1")){
%>
	alert('<%=ConvMgr.getErrMsg()%>');
<%
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_conversion.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_conversion.jsp")%>?fg=<%=fg%>';
<%
		}	else {
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/list_conversion.jsp?fg=<%=fg%>';
<%
		}
	
		if (request.getParameter("saveOption") != null && request.getParameter("saveOption").equals("N")){
%>
	window.location = '../inventario/reg_conv.jsp?fg=<%=fg%>';
<%
		} else {
%>
	window.close();
<%
		}
	} else throw new Exception(ConvMgr.getErrMsg());
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
