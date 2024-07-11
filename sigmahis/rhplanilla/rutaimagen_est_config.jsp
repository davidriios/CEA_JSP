<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==================================================================================
800008	MODIFICAR RUTA DE IMAGEN
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800007") || SecMgr.checkAccess(session.getId(),"800008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String empid=request.getParameter("empid");
String provincia = request.getParameter("prov");
String sigla = request.getParameter("sig");
String tomo = request.getParameter("tom");
String asiento = request.getParameter("asi");
String accion = request.getParameter("accion");
String key = "";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
if (mode.equalsIgnoreCase("edit"))
	{
		id="0";
		
	sql = "select distinct  a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1, nvl(a.segundo_apellido,' ') as apellido2, a.primer_nombre||' '||a.primer_apellido nombre, decode(a.foto,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("fotosimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.foto) as foto, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha from tbl_pla_estudiante a where a.compania="+(String) session.getAttribute("_companyId")+" and a.compania_uniorg="+(String) session.getAttribute("_companyId");

	cdo = SQLMgr.getData(sql);
	}
	
%>
<html> 
<head>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Ruta de Imagen - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Ruta de Imagen Edición- "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - TRANSACCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>  
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("empid",empid)%>
<%=fb.hidden("provincia",provincia)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>

<tr> 
		<td> 
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
			
				<tr> 
					<td> 	
					<div id="panel0" style="visibility:visible;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">				
							 <tr class="TextHeader">
                    <td colspan="4">Datos del Estudiante</td>
                  </tr>						
				<tr class="TextRow01">
				<td width="15%">Nombre</td>
				<td width="29%"><%=cdo.getColValue("nombre")%></td>				
				<td width="21%">Fecha de Nacimiento </td>
				<td width="35%"><%=cdo.getColValue("fecha")%></td>
				</tr>	
				<tr class="TextRow01">
				<td width="15%">Cédula</td>
				<td width="29%"><%=cdo.getColValue("provincia")%>-<%=cdo.getColValue("sigla")%>-<%=cdo.getColValue("tomo")%>-<%=cdo.getColValue("asiento")%></td>
				<td width="21%">Cargo Actual </td>
				<td width="35%">ESTUDIANTE</td>
				</tr>	
							 <tr class="TextHeader">
                    <td colspan="4">Ruta de Imagenes </td>
                </tr>						
				<tr class="TextRow01">
					<td colspan="4" align="right">Foto <%=fb.fileBox("foto",cdo.getColValue("foto"),false,false,20)%> </td>
						</tr>
				    </table>
				   </div>
				  </td>
				</tr>
			</table>			
		</td>
	</tr>				

	<tr class="TextRow02">
		<td align="right"><%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	<tr>
<%=fb.formEnd(true)%>
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
	
	Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("fotosimages"),20);
	
	String prov = (String) ht.get("provincia");
	String sig  = (String) ht.get("sigla"); 
	String tom  = (String) ht.get("tomo"); 
	String asi  = (String) ht.get("asiento");
	
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_pla_estudiante");
	cdo.addColValue("foto",(String) ht.get("foto"));
	
	cdo.addColValue("provincia",(String) ht.get("provincia"));
	cdo.addColValue("sigla",(String) ht.get("sigla"));
	cdo.addColValue("tomo",(String) ht.get("tomo"));	
	cdo.addColValue("asiento",(String) ht.get("asiento"));	
	
	
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("ue_compania",(String) session.getAttribute("_companyId"));		
		//cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("codigo");
		
		cdo.addColValue("provincia",(String) ht.get("provincia"));
		cdo.addColValue("sigla",(String) ht.get("sigla"));
		cdo.addColValue("tomo",(String) ht.get("tomo"));	
		cdo.addColValue("asiento",(String) ht.get("asiento"));	

		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);
		SQLMgr.update(cdo);
		//SQLMgr.insert(cdo);
	}
	else
	{
		
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);

		SQLMgr.update(cdo);
	}
		
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/rutaimagen_est_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/rutaimagen_est_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/rutaimagen_est_list.jsp';
<%
	}
%>
	//window.opener.location.reload(true);
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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