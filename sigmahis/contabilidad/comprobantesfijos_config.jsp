<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.contabilidad.ComprobanteF"%>
<%@ page import="issi.contabilidad.DetalleComprobante"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ComprobanteF compr = new ComprobanteF();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String change = request.getParameter("change");
int lastLineNo = 0;

if (mode == null) mode = "add";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
	    HashDet.clear();
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("El Comprobante Fijo no es válido. Por favor intente nuevamente!");

		sql = "SELECT  descripcion,estado,clase_comprob as other1 FROM tbl_con_conta_afijos_e WHERE comprobante="+code+" and compania="+(String) session.getAttribute("_companyId");
		compr = (ComprobanteF) sbb.getSingleRowBean(ConMgr.getConnection(),sql, ComprobanteF.class);		

		if (change == null)
		{
			sql = "SELECT a.renglon, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as cuenta, a.lado_mov as ladoMov, a.monto, a.nota,a.estado,a.asiento_generado as other1,'U' as action,lpad(rownum,4,'0') as key FROM tbl_con_conta_afijos_d a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania=b.compania and a.comprobante="+code+" and a.compania="+(String) session.getAttribute("_companyId")+" order by a.renglon";
		  // al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleComprobante.class);

           HashDet.clear(); 
			System.out.println("Det=\n"+sql);
			compr.setDetalle(sbb.getBeanList(ConMgr.getConnection(), sql, DetalleComprobante.class));
			
			for (int i=0; i<compr.getDetalle().size(); i++)
			{
				DetalleComprobante det = (DetalleComprobante) compr.getDetalle().get(i);

				try
				{
					HashDet.put(det.getKey(), det);
				}
				catch (Exception e)
				{
					System.out.println("Unable to addget cta "+key);
				}
			}
 		}
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript"> 
document.title=" Comprobantes Fijos  - "+document.title; 
function saveMethod()
{
  if (form0Validation())
  {  
    window.frames['itemFrame'].formDetalle.baction.value = "Guardar";
	if(window.frames['itemFrame'].calc(true))
	{
		window.frames['itemFrame'].doSubmit();
	}
	else form0BlockButtons(false);
     
  }  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MAYOR GENERAL - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

				<tr class="TextRow02">
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer" colspan="3">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Comprobantes Fijos</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td colspan="3">	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="15%">Codigo</td>
								<td width="30%"> 
								<%=fb.intBox("comprobante",code,false,false,true,20)%></td>
								<td width="15%">&nbsp;</td> 
								<td width="40%">&nbsp;</td>							
							</tr>	
							<tr class="TextRow01">
								<td width="15%">Tipo Comprobante</td>
								<td width="30%">
								<%
			StringBuffer sbSql = new StringBuffer();
			sbSql.append(" select codigo_comprob, descripcion from tbl_con_clases_comprob where estado='A' ");			
			sbSql.append(" and usado_por='U' and tipo ='C'");			
			%><%=fb.select(ConMgr.getConnection(), sbSql.toString(), "clase_comprob",compr.getOther1(), true,false, false, 0,"","text10", "")%> 
        
								</td>
								<td width="15%">&nbsp;</td> 
								<td width="40%">&nbsp;</td>							
							</tr>
							<tr class="TextRow01">
								<td width="15%">Descripci&oacute;n</td>
								<td colspan="3"><%=fb.textBox("descripcion",compr.getDescripcion(),true,false,false,80,100)%></td>							
							</tr>	
							<tr class="TextRow01">
								<td>Estado</td>
								<td colspan="3"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",compr.getEstado(),false,false,0)%></td>							
							</tr>													
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" colspan="3">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Detalle del Comprobante</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td colspan="3">	
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../contabilidad/detallecomprobantes_config.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>"></iframe>
					</td>
				</tr>
				  
				<tr class="TextRow01">
					<td width="60%" align="right">Totales del Detalle</td>
					<td width="10%" align="right" >DB <%=fb.decBox("totalDb","",false,false,true,10,null,null,"")%></td>
					<td width="30%" align="left">CR <%=fb.decBox("totalCr","",false,false,true,10,null,null,"")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="3">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
  code = request.getParameter("comprobante");
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/comprobantesfijos_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/comprobantesfijos_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/comprobantesfijos_list.jsp';
<%
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>