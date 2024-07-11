<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.DevDetSolPac"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDevMateriales" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDetMat" scope="session" class="java.util.Vector" />

<%
/**
========================================================================================
========================================================================================
**/
SecMgr.setConnection(ConMgr);%><%
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String mode = request.getParameter("mode");
String appendFilter = "", appendFilter1 = "";
String fp = request.getParameter("fp");
String fg= request.getParameter("fg");
String change = request.getParameter("change");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codAlmacen = request.getParameter("codAlmacen");
String sala = request.getParameter("sala"); 
String empresa = request.getParameter("empresa"); 


String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = cDateTime.substring(6,10);
int devLastLineNo = 0;
String codigo="",descripcion="";

if (fg == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("devLastLineNo") != null) devLastLineNo = Integer.parseInt(request.getParameter("devLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{  appendFilter = ""; 
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  
	if (request.getParameter("searchQuery")!= null)
  {  appendFilter = "";  appendFilter1 = "";
    nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		System.out.println("nextval...ahora con N..."+nextVal);
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
	if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
	if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
  {  
		appendFilter = "and upper(e.COD_ARTICULO) like '%"+request.getParameter("code").toUpperCase()+"%' ";
    	codigo = request.getParameter("code");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  { 
    	appendFilter = " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");    	
  }
 
 if (fg.equalsIgnoreCase("DM"))
	{		


sql="select y.* from (select distinct  e.cod_familia||'-'||e.cod_clase||'-'||e.cod_articulo as codigo, e.cod_familia , e.cod_clase , e.cod_articulo , a.descripcion ,a.cod_medida ,to_char(nvl(e.precio,0),'999,999,999,990.00') precio,nvl(e.costo,0)costo, nvl(sum(e.cantidad),0) cantidadSol,nvl(sum(e.cantidad),0)- nvl(x.cantdev,0) cantidad, c.descripcion sala ,c.codigo cod_centro, nvl(x.cantdev,0) cantDev, (select af.tipo_servicio from tbl_inv_familia_articulo af where  af.cod_flia = e.cod_familia and  af.compania = e.compania ) as tipoServicio from tbl_inv_articulo a , tbl_inv_entrega_material em, tbl_inv_detalle_entrega e ,tbl_inv_solicitud_pac sp ,tbl_cds_centro_servicio c , (select sum(cantidad) cantdev, b.cod_familia,  b.cod_clase, b.cod_articulo ,b.precio,nvl(b.costo,0) as costo from tbl_inv_devolucion_pac a, tbl_inv_detalle_paciente b where a.compania = b.compania and a.anio = b.anio_devolucion and a.num_devolucion = b.num_devolucion and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.pac_id = "+pacId+" and a.adm_secuencia = "+noAdmision+"and a.codigo_almacen = "+codAlmacen+" and a.estado <> 'A'  and a.sala_cod =  "+sala+" group by b.cod_familia, b.cod_clase, b.cod_articulo,b.precio,nvl(b.costo,0))x where e.cod_articulo = a.cod_articulo and x.cod_articulo(+) = e.cod_articulo and e.precio = x.precio(+) and nvl(e.costo,0) = x.costo(+)   and a.compania =  "+(String) session.getAttribute("_companyId")+" and em.compania = sp.compania and em.pac_anio = sp.anio and em.pac_solicitud_no  = sp.solicitud_no and c.compania_unorg = sp.compania and c.codigo = sp.centro_servicio and e.compania = em.compania and e.no_entrega = em.no_entrega and e.anio = em.anio and em.compania =  "+(String) session.getAttribute("_companyId")+appendFilter+"  and em.adm_secuencia = "+noAdmision+" and em.pac_id =  "+pacId+"  and em.codigo_almacen = "+codAlmacen+" and sp.centro_servicio= "+sala+" group by e.cod_familia ,e.cod_clase ,e.cod_articulo,e.compania,a.descripcion ,a.cod_medida ,e.precio ,c.descripcion ,c.codigo , x.cantdev,nvl(e.costo,0) order by a.descripcion ) y where y.cantidad > 0 ";


al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
		
}
  
	
if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
		
  int preVal=Integer.parseInt(previousVal);

  int nxtVal=Integer.parseInt(nextVal);
	 
  if (nxtVal<=rowCount)
	{ nVal=nxtVal;
	}
  else nVal=rowCount;
  
  if(rowCount==0) pVal=0;
  else pVal=preVal;
		
//--------------------------------------------------

%>
<html>
<head>
<%@ include file="nocache.jsp"%>
<%@ include file="header_param.jsp"%>
<script language="javascript">
document.title = 'Materiales y Medicamentos de Pacientes  - '+document.title;
function isDuplicated(k)
{
	var obj=eval('document.insumo.id'+replaceAll(eval('document.insumo.codigo'+k).value,'-','_'));
	if(obj.length!=undefined)for(i=0;i<obj.length;i++)if(k!=obj[i].value)eval('document.insumo.check'+obj[i].value).disabled=eval('document.insumo.check'+k).checked;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="title.jsp" flush="true">
	<jsp:param name="title" value="MATERIALES Y MEDICAMENTOS DE PACIENTES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="1">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
		  <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("fg",""+fg)%>
			<%=fb.hidden("mode",""+mode)%>
		  <%=fb.hidden("codAlmacen",codAlmacen)%>	
			<%=fb.hidden("sala",sala)%>
		  <%=fb.hidden("pacId",pacId)%>
		  <%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("devLastLineNo",""+devLastLineNo)%>
			<%=fb.hidden("empresa",""+empresa)%>
		<td width="50%"><cellbytelabel>C&oacute;digo</cellbytelabel>
			<%=fb.textBox("code","",false,false,false,30,null,null,null)%></td>
		
		<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>	
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>
<!--------------------------------------------------------  --->
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	  <tr>
  			  <td align="right">&nbsp;</td>
 	 </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("insumo",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("mode",""+mode)%>
<%=fb.hidden("codAlmacen",codAlmacen)%>	
<%=fb.hidden("sala",sala)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("devLastLineNo",""+devLastLineNo)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("empresa",""+empresa)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("descripcion",""+descripcion)%>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>	

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">




	<tr class="TextHeader" align="center">
							
							<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Unidad M</cellbytelabel>.</td>
							<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Sala</cellbytelabel></td>
							<td width="5%">&nbsp;</td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("familia"+i,cdo.getColValue("cod_familia"))%>
		<%=fb.hidden("clase"+i,cdo.getColValue("cod_clase"))%>
		<%=fb.hidden("articulo"+i,cdo.getColValue("cod_articulo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("medida"+i,cdo.getColValue("cod_medida"))%>
		<%=fb.hidden("cantidadSol"+i,cdo.getColValue("cantidadSol"))%>
		<%=fb.hidden("cantidad"+i,cdo.getColValue("cantidad"))%>
		<%=fb.hidden("cantDev"+i,cdo.getColValue("cantDev"))%>
		<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
		<%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
		<%=fb.hidden("centro"+i,cdo.getColValue("cod_centro"))%>
		<%=fb.hidden("no_entrega"+i,cdo.getColValue("noEntrega"))%>
		<%=fb.hidden("anio_entrega"+i,cdo.getColValue("anioEntrega"))%>
		<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipoServicio"))%>
		<%=fb.hidden("renglon"+i,""+i+1)%>
		<%=fb.hidden("id"+cdo.getColValue("codigo").replaceAll("-","_"),""+i)%>
		<tr class="<%=color%>">
		    
				<td><%=cdo.getColValue("descripcion")%></td>
				<td><%=cdo.getColValue("cod_medida")%></td>
				<td><%=Double.parseDouble(cdo.getColValue("precio"))%></td>
				<td><%=cdo.getColValue("cantidad")%></td>
				<td><%=cdo.getColValue("sala")%></td>
				<td align="center"><%=(vDetMat.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false,null,null,"onClick=\"javascript:isDuplicated("+i+")\"")%></td>
		</tr>
<%
}
%>				
</table>
		</td>
	</tr>		
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1 )?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount<=nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="footer.jsp"%>
</body>
</html>
<%
}//get 
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	int rg=0;
	for (int i=0; i<size; i++)
	{ 
		if (request.getParameter("check"+i) != null)
		{
					DevDetSolPac detal = new DevDetSolPac();
					rg++;
					detal.setRenglon(""+rg);
					detal.setCodFamilia(request.getParameter("familia"+i));
					detal.setCodClase(request.getParameter("clase"+i));
					detal.setCodArticulo(request.getParameter("articulo"+i));

					detal.setCantidadSol(request.getParameter("cantidadSol"+i));
					detal.setCantidad(request.getParameter("cantidad"+i));
					detal.setCantDev(request.getParameter("cantDev"+i));
					detal.setPrecio(request.getParameter("precio"+i));
					detal.setCosto(request.getParameter("costo"+i));
					detal.setAnioDevolucion(request.getParameter("anio"));
					detal.setMedida(request.getParameter("medida"+i));
					detal.setCompania(request.getParameter("compania"));
					detal.setDescripcion(request.getParameter("descripcion"+i));
					detal.setAnioEntrega(request.getParameter("anio_entrega"+i));
					detal.setNoEntrega(request.getParameter("no_entrega"+i));
					detal.setCentro(request.getParameter("centro"+i));
					detal.setTipoServicio(request.getParameter("tipo_servicio"+i));
					detal.setEntregas(request.getParameter("cantidadSol"+i));
					
					detal.setKey(request.getParameter("codigo"+i));
					
			devLastLineNo++;
			String key = "";
			if (devLastLineNo < 10) key = "00"+devLastLineNo;
			else if (devLastLineNo < 100) key = "0"+devLastLineNo;
			else key = ""+devLastLineNo;
			//cdo.addColValue("key",key);
	
			try
			{
				iDevMateriales.put(key,detal);
					vDetMat.addElement(detal.getKey());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// if checked
	}//for
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&devLastLineNo="+devLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&empresa="+request.getParameter("empresa")+"&seccion="+request.getParameter("seccion")+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&observacion="+request.getParameter("observacion"));
			return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
	
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&devLastLineNo="+devLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&pacId="+request.getParameter("pacId")+"&empresa="+request.getParameter("empresa")+"&seccion="+request.getParameter("seccion")+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&observacion="+request.getParameter("observacion"));
		
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fg.equalsIgnoreCase("DM"))
	{

%>
	window.opener.location = '../inventario/dev_pac_det.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&devLastLineNo=<%=devLastLineNo%>&fg=<%=fg%>&fp=<%=fp%>';
<%
	}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>