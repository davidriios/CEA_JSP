
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String index = request.getParameter("index");
String fg = request.getParameter("fg");
String aplicar = request.getParameter("aplicar");

if (fg == null)fg="";
if (aplicar == null)aplicar="";
int cantidad = 0;

if (index == null) throw new Exception("Indice no es válido. Por favor intente nuevamete!");
String codArticulo = request.getParameter("codArticulo");
if(codArticulo==null)codArticulo="";
if (request.getParameter("cantidad") != null && !request.getParameter("cantidad").equals("")) cantidad = Integer.parseInt(request.getParameter("cantidad"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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
  String codigo="",nombre ="",tipo="",estado="";

if (request.getParameter("estado") != null )
 { 
 estado = request.getParameter("estado");
 if (!request.getParameter("estado").equals("")) 
		{
		appendFilter = appendFilter+" and estado_proveedor = '"+request.getParameter("estado").toUpperCase()+"' ";	
		}
		else 
		{appendFilter=appendFilter+" and upper(estado_proveedor)<> 'INA'";}
 }else
 {
 appendFilter=appendFilter+" and upper(estado_proveedor)<> 'INA'";
 }	
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(cod_provedor) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  { 
    appendFilter += " and upper(nombre_proveedor) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }
  tipo = request.getParameter("tipo");
  if(tipo == null)tipo ="";
  	sql ="select distinct 'A' type, a.cod_provedor codigo, a.nombre_proveedor nombre,a.ruc,'PROVEEDORES CON RECEPCIONES' as descType,to_char(LPAD(a.compania,2,0)||LPAD("+codArticulo+",2,0)||(select to_char(nvl(max(to_number(secuencia_placa)),0)+1) from tbl_con_temp_activo where compania = a.compania )) nuevaPlaca from tbl_inv_recepcion_material b, tbl_com_proveedor a where (b.cod_proveedor = a.cod_provedor and b.compania = a.compania) and b.compania="+(String) session.getAttribute("_companyId")+appendFilter;

	if (tipo.trim().equals("A"))sql +=" union all  select distinct 'P' type, a.cod_provedor codigo, a.nombre_proveedor nombre,a.ruc,'PROVEEDORES SIN RECEPCIONES' as descType , '0' from tbl_com_proveedor a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and not exists (select 1 from tbl_inv_recepcion_material b where b.cod_proveedor = a.cod_provedor and b.compania = a.compania)";
	else if (tipo.trim().equals("P"))sql =" select distinct 'P' type, a.cod_provedor codigo, a.nombre_proveedor nombre,a.ruc,'PROVEEDORES SIN RECEPCIONES' as descType,to_char(LPAD(a.compania,2,0)||LPAD("+codArticulo+",2,0)||(select to_char(nvl(max(to_number(secuencia_placa)),0)+1) from tbl_con_temp_activo where compania = a.compania )) nuevaPlaca from tbl_com_proveedor a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and not exists (select 1 from tbl_inv_recepcion_material b where b.cod_proveedor = a.cod_provedor and b.compania = a.compania)";

	sql +=" order by 1,2";
if(request.getParameter("tipo") != null){
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_com_proveedor Where compania="+(String) session.getAttribute("_companyId")+appendFilter);
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
document.title = 'Proveedor - '+document.title;

function setDetails(k)
{
		
		if(eval('document.proveedor.noFactura'+k).value==''||eval('document.proveedor.vidaUtil'+k).value=='')alert('Complete los campos requeridos');
		else{
		<%if(fg.trim().equals("ACT")){
		if(aplicar.trim().equals("T")){	
		for (int i=0;i<cantidad;i++){
		%>
		window.opener.document.form0.actNumFactura<%=i%>.value = eval('document.proveedor.noFactura'+k).value;
		window.opener.document.form0.actCodProveedor<%=i%>.value = eval('document.proveedor.codigo'+k).value;
		window.opener.document.form0.actDescProveedor<%=i%>.value = eval('document.proveedor.nombre'+k).value;
		window.opener.document.form0.actPlaca<%=i%>.value = eval('document.proveedor.noPlaca'+k).value;
		window.opener.document.form0.actVidaUtil<%=i%>.value = eval('document.proveedor.vidaUtil'+k).value;
			<%if(i==0){%>
				window.opener.document.form0.actNumFactura.value = eval('document.proveedor.noFactura'+k).value;
				window.opener.document.form0.actCodProveedor.value = eval('document.proveedor.codigo'+k).value;
				window.opener.document.form0.actPlaca.value = eval('document.proveedor.noPlaca'+k).value;
				window.opener.document.form0.actVidaUtil.value = eval('document.proveedor.vidaUtil'+k).value;
				window.opener.document.form0.actDescProveedor.value = eval('document.proveedor.nombre'+k).value;
			<%}%>
		<%}}//end for
		else{%>
		
		window.opener.document.form0.actNumFactura<%=index%>.value = eval('document.proveedor.noFactura'+k).value;
		window.opener.document.form0.actCodProveedor<%=index%>.value = eval('document.proveedor.codigo'+k).value;
		window.opener.document.form0.actDescProveedor<%=index%>.value = eval('document.proveedor.nombre'+k).value;
		window.opener.document.form0.actPlaca<%=index%>.value = eval('document.proveedor.noPlaca'+k).value;
		window.opener.document.form0.actVidaUtil<%=index%>.value = eval('document.proveedor.vidaUtil'+k).value;
		
		window.opener.document.form0.actNumFactura.value = eval('document.proveedor.noFactura'+k).value;
		window.opener.document.form0.actCodProveedor.value = eval('document.proveedor.codigo'+k).value;
		window.opener.document.form0.actPlaca.value = eval('document.proveedor.noPlaca'+k).value;
		window.opener.document.form0.actVidaUtil.value = eval('document.proveedor.vidaUtil'+k).value;
		window.opener.document.form0.actDescProveedor.value = eval('document.proveedor.nombre'+k).value;

		<%}%>
		/*if(window.opener.document.form1.actNumFactura<%=index%>)window.opener.document.form1.actNumFactura<%=index%>.value = eval('document.proveedor.noFactura'+k).value;
		if(window.opener.document.form1.actCodProveedor<%=index%>)window.opener.document.form1.actCodProveedor<%=index%>.value = eval('document.proveedor.codigo'+k).value;
		if(window.opener.document.form1.actPlaca<%=index%>)window.opener.document.form1.actPlaca<%=index%>.value = eval('document.proveedor.noPlaca'+k).value;
		if(window.opener.document.form1.actVidaUtil<%=index%>)window.opener.document.form1.actVidaUtil<%=index%>.value = eval('document.proveedor.vidaUtil'+k).value;*/
		
		window.opener.focus();
		window.close();
		
		<%}else {%>
		window.opener.document.form1.actNumFactura<%=index%>.value = eval('document.proveedor.noFactura'+k).value;
		window.opener.document.form1.actCodProveedor<%=index%>.value = eval('document.proveedor.codigo'+k).value;
		window.opener.document.form1.actPlaca<%=index%>.value = eval('document.proveedor.noPlaca'+k).value;
		window.opener.document.form1.actVidaUtil<%=index%>.value = eval('document.proveedor.vidaUtil'+k).value;
		window.opener.focus();
		window.close();
		<%}%>
		}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PROVEEDOR"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
    <tr>
        <td align="right">&nbsp;</td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
			    <tr class="TextFilter">	                    
					<%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codArticulo",codArticulo)%>
					<%=fb.hidden("cantidad",""+cantidad)%>
					<%=fb.hidden("fg",fg)%>		
					<%=fb.hidden("aplicar",aplicar)%>					
				    <td width="50%">Tipo:<%=fb.select("tipo","R=PROVEEDORES CON RECEPCIONES,P=PROVEEDORES SIN RECEPCIONES,A=TODOS",tipo)%>C&oacute;digo					
					<%=fb.textBox("codigo","",false,false,false,30)%>
					</td>
				    <td width="30%">Nombre
					<%=fb.textBox("nombre","",false,false,false,30)%>
					</td>
				    <td width="20%">Estado
					<%=fb.select("estado","ACT=Activo, INA=Inactivo",null)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;</td>
    </tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("nombre",""+nombre)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("tipo",""+tipo)%>
				<%=fb.hidden("codArticulo",codArticulo)%>
				<%=fb.hidden("cantidad",""+cantidad)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("aplicar",aplicar)%>	
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("nombre",""+nombre)%>
					<%=fb.hidden("estado",""+estado)%>
					<%=fb.hidden("tipo",""+tipo)%>
					<%=fb.hidden("codArticulo",codArticulo)%>
					<%=fb.hidden("fg",fg)%>	
					<%=fb.hidden("cantidad",""+cantidad)%>
					<%=fb.hidden("aplicar",aplicar)%>	
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

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<%fb = new FormBean("proveedor");%>
		<%=fb.formStart(true)%>
			<%if(al.size()==0){%>
			<tr class="TextHeader">
				<td width="20%">C&oacute;digo</td>
				<td width="45%">Nombre</td>
				<td width="10%">No. Factura</td>
				<td width="5%">Vida Util</td>
				<td width="10%">No. Placa</td>
				<td width="10%">&nbsp;</td>
			</tr>				
				<%}String  groupBy ="";
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";

				if(i==0){%>
				<tr class="TextRow02">
					<td colspan="6">SIGUIENTE SECUENCIA DE PLACAS AUTOMATICAS: <font color="#FF0000" size="+3"><%=cdo.getColValue("nuevaPlaca")%></font>(compañia + codigo de articulo + Secuencia de activo)</td>
				</tr>
				<tr class="TextHeader">
					<td width="20%">C&oacute;digo</td>
					<td width="45%">Nombre</td>
					<td width="10%">No. Factura</td>
					<td width="5%">Vida Util</td>
					<td width="10%">No. Placa</td>
					<td width="10%">&nbsp;</td>
				</tr>
				
				<%}if(!groupBy.trim().equals(cdo.getColValue("type"))){%>
				
					<tr class="TextHeader02">
						<td colspan="6"><%=cdo.getColValue("descType")%></td>
					</tr>

				<%}%>			

				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=fb.textBox("noFactura"+i,"",true,false,false,15,22)%></td>
					<td align="center"><%=fb.intBox("vidaUtil"+i,"",true,false,false,5,3)%></td>
					<td align="center"><%=fb.textBox("noPlaca"+i,"",false,false,false,10,20)%></td>
					<td align="center">
					<a href="javascript:setDetails(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Seleccionar</a>
					</td>
				</tr>
				
				<%groupBy = cdo.getColValue("type");
				}
				%>							
			</table>
		</div>
	 </div>	

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	<%=fb.formEnd(true)%>
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("nombre",""+nombre)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("tipo",""+tipo)%>
				<%=fb.hidden("codArticulo",codArticulo)%>
				<%=fb.hidden("fg",fg)%>	
				<%=fb.hidden("cantidad",""+cantidad)%>
				<%=fb.hidden("aplicar",aplicar)%>	
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("nombre",""+nombre)%>
					<%=fb.hidden("estado",""+estado)%>
					<%=fb.hidden("tipo",""+tipo)%>
					<%=fb.hidden("codArticulo",codArticulo)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("cantidad",""+cantidad)%>
					<%=fb.hidden("aplicar",aplicar)%>	
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>
