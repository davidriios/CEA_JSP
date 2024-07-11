<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100015") || SecMgr.checkAccess(session.getId(),"100016") || SecMgr.checkAccess(session.getId(),"100017") || SecMgr.checkAccess(session.getId(),"100018"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String centroCode = request.getParameter("centroCode");
String tipoCdsCode = request.getParameter("tipoCdsCode");
String tipoServCode = request.getParameter("tipoServCode");
String servKey = "";
String index = request.getParameter("i");

if (request.getMethod().equalsIgnoreCase("GET"))
{ 
  if (centroCode == null) throw new Exception("El Centro Servicio no es válido. Por favor intente nuevamente!");   
  if (tipoCdsCode == null) throw new Exception("El Tipo del Centro Servicio no es válido. Por favor intente nuevamente!");
  if (tipoServCode == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");
  
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
 
	if (request.getParameter("codigo") != null)
	{
		appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";

    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
	}
	else if (request.getParameter("descripcion") != null)
	{
		appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";

    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
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
    if (!tipoServCode.equals("01")) /*HABITACION*/
	{  
	  if (tipoServCode.equals("02") && (tipoCdsCode.equals("E") || tipoCdsCode.equals("T")))/*MATERIALES*/
	  { 	 
        sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+" and estatus='A'"+appendFilter+" ORDER BY descripcion";		   
       	rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
        servKey = "3";
		
      }else if (tipoServCode.equals("02") && tipoCdsCode.equals("I")){  /*MATERIALES*/ 
	    
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion"; 	 
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("03") && (tipoCdsCode.equals("E") || tipoCdsCode.equals("T"))){  /*MEDICAMENTOS*/
		
			sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
			servKey = "3";
			
	  }else if (tipoServCode.equals("03") && tipoCdsCode.equals("I")){  /*MEDICAMENTOS*/
		
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";   	    
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("04") && (tipoCdsCode.equals("T") || tipoCdsCode.equals("E"))){  /* OXIGENO Y ANESTESIA */
        
			sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
			servKey = "3";
			
	  }else if (tipoServCode.equals("04") && tipoCdsCode.equals("I")){  /* OXIGENO Y ANESTESIA */
		
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if(tipoServCode.equals("05") && (tipoCdsCode.equals("I") || tipoCdsCode.equals("E"))){  /*USO EQUIPOS*/
		
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion"; 
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("05") && tipoCdsCode.equals("T")){  /*USO EQUIPOS*/
		
			sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
			servKey = "3";
			
	  }else if (tipoServCode.equals("06") && tipoCdsCode.equals("I")){  /*AMBULANCIA*/
        
	        sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
            servKey = "4";
						
	  }else if (tipoServCode.equals("06") && (tipoCdsCode.equals("E") || tipoCdsCode.equals("T"))){  /*AMBULANCIA*/
        
	        sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
			servKey = "3";
			
	  }else if (tipoServCode.equals("07") && tipoCdsCode.equals("I")){  /*PROCEDIMIENTO*/  
	    
			sql = "SELECT codigo, DECODE(observacion,null,descripcion,observacion) as descripcion, precio FROM tbl_cds_procedimiento WHERE precio!=null and cod_cds="+centroCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) ROM tbl_cds_procedimiento WHERE precio!=null and cod_cds="+centroCode+appendFilter);
			servKey = "1";
				
	  }else if (tipoServCode.equals("07") && (tipoCdsCode.equals("T") || tipoCdsCode.equals("E"))){ /*PROCEDIMIENTO*/  
	    
			sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");			
			servKey = "3";
			
	  }else if (tipoServCode.equals("30")){  /*OTROS CARGOS*/
        
	        sql = "SELECT to_char(codigo), descripcion, precio FROM tbl_fac_otros_cargos WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" and codigo_tipo!=null and activo_inactivo='A' ORDER BY descripcion";			
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_fac_otros_cargos WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" and codigo_tipo!=null and activo_inactivo='A'");
			servKey = "2";
						
	  }else if (tipoServCode.equals("09") && (tipoCdsCode.equals("T") || tipoCdsCode.equals("E"))){  /* PENSION DE RECOBRO */ 
        
	        sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
            servKey = "3";
						
	  }else if (tipoServCode.equals("09") && tipoCdsCode.equals("I")){  /* PENSION DE RECOBRO */
	   	
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("10") && (tipoCdsCode.equals("T") || tipoCdsCode.equals("E"))){  /* PENSION SALON DE OPERACIONES */         
        
	        sql = "SELECT codigo, descripcion, precio, cod_centro_servicio, cpt FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A' ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_cds_producto_x_cds WHERE cod_centro_servicio="+centroCode+" and tser="+tipoServCode+appendFilter+" and estatus='A'");
			servKey = "3";
			
	  }else if (tipoServCode.equals("10") && tipoCdsCode.equals("I")){  /* PENSION SALON DE OPERACIONES */
        
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("11")){  /* PENSION CUARTO DE URGENCIA */ 
        
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("12")){  /*PENSION OBSTETRICIA*/
        
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("13")){  /*MORGUE*/
        
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
			
	  }else if (tipoServCode.equals("14")){   /* SERVICIOS DE ANESTESIA */
        
			sql = "SELECT codigo, descripcion, precio_venta as precio, compania FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter+" ORDER BY descripcion";
			rowCount = CmnMgr.getCount("select count(*) FROM tbl_sal_uso WHERE compania="+(String) session.getAttribute("_companyId")+" and tipo_servicio="+tipoServCode+appendFilter);
			servKey = "4";
	  }

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
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
document.title = 'Lista para Detalle de Descuento - '+document.title;

function returnValue(i)
{
  var code = eval('document.form01.codigo'+i).value;  
  var name = eval('document.form01.descripcion'+i).value;
  var servKey = eval('document.form01.servKey'+i).value;
  var index = eval('document.form01.index'+i).value;
  
  if (servKey=="1")
  {
  eval('window.opener.document.formDetalle.procedimiento'+index).value = code;
  eval('window.opener.document.formDetalle.servicioCode'+index).value = code;
  eval('window.opener.document.formDetalle.servicio'+index).value = name;
  eval('window.opener.document.formDetalle.servKey'+index).value = servKey;
  alert('FINALIZANDO CUANDO SERVKEY = 1 PROCEDIMIENTO');
  window.close();
  }
  else if (servKey=="2") 
  {
  eval('window.opener.document.formDetalle.otros_cargos'+index).value = code;
  eval('window.opener.document.formDetalle.servicioCode'+index).value = code;
  eval('window.opener.document.formDetalle.servicio'+index).value = name;
  eval('window.opener.document.formDetalle.servKey'+index).value = servKey;
  alert('FINALIZANDO CUANDO SERVKEY = 2 OTROS CARGOS');
  window.close();
  }
  else if (servKey=="3") 
  {
  eval('window.opener.document.formDetalle.cds_producto'+index).value = code;
  eval('window.opener.document.formDetalle.servicioCode'+index).value = code;
  eval('window.opener.document.formDetalle.servicio'+index).value = name;
  eval('window.opener.document.formDetalle.servKey'+index).value = servKey;
  alert('FINALIZANDO CUANDO SERVKEY = 3 PRODUCTO');
  window.close();
  }
  else if (servKey=="4") 
  {
  eval('window.opener.document.formDetalle.cod_uso'+index).value = code;
  eval('window.opener.document.formDetalle.servicioCode'+index).value = code;
  eval('window.opener.document.formDetalle.servicio'+index).value = name;
  eval('window.opener.document.formDetalle.servKey'+index).value = servKey;
  alert('FINALIZANDO CUANDO SERVKEY = 4 USO');
  window.close();
  }      
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - DETALLE DE DESCUENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			    <tr class="TextFilter">		
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="40%"><cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
				<%
				fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>				
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
	
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%
			   fb = new FormBean("form01",request.getContextPath()+request.getServletPath(),FormBean.POST);
			%>
			<%=fb.formStart()%>
			<tr class="TextHeader" align="center">
				<td width="5%">&nbsp;</td>
				<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="55%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width="15%"><cellbytelabel>Precio</cellbytelabel></td>
			</tr>
			<%
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
			%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%><%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%><%=fb.hidden("servKey"+i,servKey)%><%=fb.hidden("index"+i,index)%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)">
				<td align="right"><%=preVal + i%>&nbsp;</td>
				<td><%=cdo.getColValue("codigo")%></td>
				<td><%=cdo.getColValue("descripcion")%></td>
				<td><%=cdo.getColValue("precio")%></td>				
			</tr>
			<%
			}
			%>
			<%=fb.formEnd(true)%>
			</table>
	
	<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
