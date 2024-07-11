<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.Descuento"%>
<%@ page import="issi.caja.DetalleDescuento"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="DescMgr" scope="page" class="issi.caja.DescuentoMgr" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900093") || SecMgr.checkAccess(session.getId(),"900094") || SecMgr.checkAccess(session.getId(),"900095") || SecMgr.checkAccess(session.getId(),"900096") || SecMgr.checkAccess(session.getId(),"900097") || SecMgr.checkAccess(session.getId(),"900098") || SecMgr.checkAccess(session.getId(),"900099") || SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
DescMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String descCode = request.getParameter("descCode");
String centroCode = request.getParameter("centroCode");
String tipoCdsCode = request.getParameter("tipoCdsCode");
String key = "";
String filter = " and recibe_mov='S'";
int lastLineNo = 0;

Descuento desc = new Descuento();

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (mode.equalsIgnoreCase("add"))
  { 
	   HashDet.clear(); 	 	 
  }else{
		  if (descCode == null) throw new Exception("El Descuento no es válido. Por favor intente nuevamente!");
		  if (centroCode == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
		  if (tipoCdsCode == null) throw new Exception("El Tipo de Centro de Servicio no es válido. Por favor intente nuevamente!");
		  
		  sql = "SELECT b.descripcion as centro, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, c.descripcion as cuenta FROM tbl_cja_ctas_descuentos a, tbl_cds_centro_servicio b, tbl_con_catalogo_gral c WHERE a.centro_servicio=b.codigo and a.cta1=c.cta1(+) and a.cta2=c.cta2(+) and a.cta3=c.cta3(+) and a.cta4=c.cta4(+) and a.cta5=c.cta5(+) and a.cta6=c.cta6(+) and a.compania=c.compania(+) and a.descuento="+descCode+" and a.centro_servicio="+centroCode+" and a.compania="+(String) session.getAttribute("_companyId");
		  desc = (Descuento) sbb.getSingleRowBean(ConMgr.getConnection(),sql, Descuento.class);
			
		  sql = "SELECT a.secuencia, a.tipo_servicio as tipoServCode, b.descripcion as tipoServ, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, c.descripcion as cuenta, a.procedimiento as proceCode, d.descripcion as proce, a.otros_cargos as otrosCargosCode, e.descripcion as otrosCargos, a.cds_producto as productoCode, f.descripcion as producto, a.cod_uso as usoCode, g.descripcion as uso FROM tbl_cja_ctas_descuentos_det a, tbl_cds_tipo_servicio b, tbl_con_catalogo_gral c, tbl_cds_procedimiento d, tbl_fac_otros_cargos e, tbl_cds_producto_x_cds f, tbl_sal_uso g WHERE a.tipo_servicio=b.codigo and a.cta1=c.cta1(+) and a.cta2=c.cta2(+) and a.cta3=c.cta3(+) and a.cta4=c.cta4(+) and a.cta5=c.cta5(+) and a.cta6=c.cta6(+) and a.compania=c.compania(+) and a.procedimiento=d.codigo(+) and a.otros_cargos=e.codigo(+) and a.compania=e.compania(+) and a.cds_producto=f.codigo(+) and a.centro_servicio=f.cod_centro_servicio(+) and a.cod_uso=g.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.descuento="+descCode+" and a.centro_servicio="+centroCode+" order by a.secuencia";
		  al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDescuento.class);                   
		  	
		  HashDet.clear(); 
			
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  HashDet.put(key, al.get(i-1));
			  lastLineNo = i;
		    }  	  			
  }
%>
<html>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script> 
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function adjustIFrameSize (iframeWindow)
{
	if (iframeWindow.document.height)
	{
		var iframeElement = document.getElementById (iframeWindow.name);
		iframeElement.style.height = (parseInt(iframeWindow.document.height,10) + 15) + 'px';
	}
	else if (document.all)
	{
		var iframeElement = document.all[iframeWindow.name];
		if (iframeWindow.document.compatMode &&	iframeWindow.document.compatMode != 'BackCompat') 
		{
			iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 5 + 'px';
		}
		else
		{
			iframeElement.style.height = iframeWindow.document.body.scrollHeight + 5 + 'px';
		}
	}
}
/*function adjustIFrameSize (iframeWindow) 
{
	if (iframeWindow.document.height) {
	var iframeElement = document.getElementById (iframeWindow.name);
	iframeElement.style.height = (parseInt(iframeWindow.document.height,10) + 16) + 'px';
//            iframeElement.style.width = iframeWindow.document.width + 'px';
	}
	else if (document.all) {
	var iframeElement = document.all[iframeWindow.name];
	if (iframeWindow.document.compatMode &&
	iframeWindow.document.compatMode != 'BackCompat')
	{
	iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 5 + 'px';
	}
	else {
	iframeElement.style.height = iframeWindow.document.body.scrollHeight + 5 + 'px';
	}
	}
}*/
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Contrato Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Contrato Edición - "+document.title;
<%}%>
function addCentro()
{
  abrir_ventana1('../admision/habitacion_centroservicio_list.jsp?id=5');
}
function addCuenta()
{
  abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=18&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - CTAS CONTABLES ASOCIADAS A DESCUENTOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">   
<tr>  
	<td class="TableBorder">   

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center"> 

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
	<tr>    
		<td>   
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPrincipal" align="left" width="100%" onClick="javascript:verocultar(panel0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%" ><cellbytelabel>DESCUENTO</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>  	
					<div id="panel0" style="visibility:visible;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">										
							<tr class="TextRow01">
								<td width="15%"><cellbytelabel>Centro Servicio</cellbytelabel></td><%=fb.hidden("tipoCdsCode",tipoCdsCode)%>
								<td width="45%"><%=fb.textBox("centroCode",centroCode,true,false,true,5)%><%=fb.textBox("centro",desc.getCentro(),true,false,true,40)%><%=fb.button("btncentro","...",false,false,null,null,"onClick=\"javascript:addCentro()\"")%></td>
								<td width="18%"><cellbytelabel>Descuento</cellbytelabel></td> 
								<td width="22%"><%=fb.select("descCode","26=Jubilados,20=Cortesias Varias,30=Cortesias Empleados,23=Deducibles,25=Previsión Social,0=Otros",descCode)%></td>	 				
							</tr>
							<tr class="TextRow01"> 
							    <td><cellbytelabel>Cta. Contable</cellbytelabel></td>
								<td colspan="3"><%=fb.textBox("cta1",desc.getCta1(),false,false,true,3)%><%=fb.textBox("cta2",desc.getCta2(),false,false,true,3)%><%=fb.textBox("cta3",desc.getCta3(),false,false,true,3)%><%=fb.textBox("cta4",desc.getCta4(),false,false,true,3)%><%=fb.textBox("cta5",desc.getCta5(),false,false,true,3)%><%=fb.textBox("cta6",desc.getCta6(),false,false,true,3)%><%=fb.textBox("cuenta",desc.getCuenta(),false,false,true,40)%><%=fb.button("btncuenta","...",false,false,null,null,"onClick=\"javascript:addCuenta()\"")%></td>									
							</tr>
						</table>
					</div>
					</td>     
				</tr>   
			</table>			
		</td>  
	</tr>  
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TOtros" align="left" width="100%" onClick="javascript:verocultar(panel1)" onMouseover="bcolor('#5c7188','TOtros');" onMouseout="bcolor('#8f9ba9','TOtros');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;<cellbytelabel>DETALLE DEL DESCUENTO</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>				
				<tr>
					<td>
					    <div id="panel1" style="inline:display;">
                    	<iframe name="detalle" id="detalle" frameborder="0" align="center" style="width:100%; height:50px;" src="../caja/detalledescuento_config.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>&centroCode=<%=centroCode%>&descCode=<%=descCode%>&tipoCdsCode=<%=tipoCdsCode%>"></iframe>
						</div>
					</td>
				</tr>
			</table>			
		</td>
	</tr>
	<tr class="TextRow01">
		<td align="right">
			<%=fb.button("save","Guardar",true,false,null, null, "onClick=\"window.frames['detalle'].doSubmit()\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
    <tr class="TextRow01">      	
		<td align="right"><cellbytelabel>CREADO POR</cellbytelabel>: <%=UserDet.getUserEmpId()%> - <%=CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")%></td>	  
	</tr>
<%=fb.formEnd(true)%>
</table>				
<%@ include file="../common/footer.jsp"%>
</div>
	
<!--STYLE DW-->
<!--*************************************************************************************************************-->	
	</td>
	<td>&nbsp;</td>
</tr> 		
</table>
</body>
</html>
<%
}//GET
else
{
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/mantenimiento_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/mantenimiento_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/mantenimiento_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(errMsg);
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