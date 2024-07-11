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
Registro Edicion de grupos de activos 
Forma ACT0310.fmb
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String ctaControl=request.getParameter("ctaControl");

String date= CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("code","0");
	}
	else
	{
		if (id == null) throw new Exception("El Codificador de Cuentas no es válido. Por favor intente nuevamente!");

sql="SELECT a.cta_control as control, a.codigo_espec as code, a.compania, a.cta1_Activo as activo1, a.cta2_activo as activo2, a.cta3_activo as activo3, a.cta4_activo as activo4, a.cta5_activo as activo5, a.cta6_activo as activo6,a.cta1_depre_acum as acumulada1, a.cta2_depre_acum as acumulada2, a.cta3_depre_acum as acumulada3,a.cta4_depre_acum as acumulada4, a.cta5_depre_acum as acumulada5, a.cta6_depre_acum as acumulada6,a.cta1_gast_depre as gasto1, a.cta2_gast_depre as gasto2, a.cta3_gast_depre as gasto3,a.cta4_gast_depre as gasto4, a.cta5_gast_depre as gasto5, a.cta6_gast_depre as gasto6, a.descripcion, nvl(a.codigo_clasif,'0') as codehacienda, a.saldo,e.descripcion namehacienda,nvl((select descripcion from tbl_con_catalogo_gral where cta1=a.cta1_activo and cta2=a.cta2_activo and cta3=a.cta3_activo and cta4=a.cta4_activo and cta5=a.cta5_activo and cta6=a.cta6_activo and compania=a.compania),' ') as descActivo,nvl((select descripcion from tbl_con_catalogo_gral where cta1=a.cta1_depre_acum and cta2=a.cta2_depre_acum and cta3=a.cta3_depre_acum and cta4=a.cta4_depre_acum and cta5=a.cta5_depre_acum and cta6=a.cta6_depre_acum and compania=a.compania),' ') as descAcum,nvl((select descripcion from tbl_con_catalogo_gral where cta1=a.cta1_gast_depre and cta2=a.cta2_gast_depre and cta3=a.cta3_gast_depre and cta4=a.cta4_gast_depre and cta5=a.cta5_gast_depre and cta6=a.cta6_gast_depre and compania=a.compania),' ') as descDepre from tbl_con_especificacion a,tbl_con_clasif_hacienda e where a.codigo_espec = '"+id+"' and a.cta_control = '"+ctaControl+"' and a.compania = "+(String) session.getAttribute("_companyId")+" and a.codigo_clasif=e.cod_clasif(+) ";
		
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<script language="javascript">
document.title="Codificador de Cuentas - Registro/Edicion - "+document.title;
function addCuenta(fp){abrir_ventana1('../common/search_catalogo_gral.jsp?fp='+fp);}
function hacienda(){abrir_ventana1('../activos/list_clasificacion.jsp?id=1');}
</script>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CODIFICADOR DE CUENTAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
			
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("saldo",cdo.getColValue("saldo"))%>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;N&uacute;mero de Cuenta</td>
				</tr>	
				<tr class="TextRow01" >
					<td width="10%">&nbsp;C&oacute;digo</td>
					<td width="90%"><%=fb.textBox("control",cdo.getColValue("control"),true,false,(!mode.trim().equalsIgnoreCase("add")),4,3)%>
					<%=fb.intBox("code",id,false,false,true,5)%><%//=id%>					
					<%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,30)%></td>				
				</tr>								
				<tr>
				  <td id="TMaletin" align="left" width="100%"  onClick="javascript:showHide(0)" style=" background-color:#770000; border-bottom:1.5pt solid #808080;" colspan="2">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr class="TextHeader">
							<td width="97%">&nbsp;<font color="#FFFFFF">Cuenta de Activo</font></td>
							<td width="3%" align="center" style="text-decoration:none; cursor:pointer">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
					</table>
				  </td>
				</tr>
				<tr>
					<td colspan="2">
						<div id="panel0" style="display:inline">
							<table width="100%" cellpadding="1" cellspacing="1" border="1" bordercolor="d0deea" style="border-collapse:collapse;">
								<tr class="TextRow01">
									<td width="90%">
										<%=fb.textBox("activo1",cdo.getColValue("activo1"),true,false,true,3)%>
										<%=fb.textBox("activo2",cdo.getColValue("activo2"),true,false,true,3)%>
										<%=fb.textBox("activo3",cdo.getColValue("activo3"),true,false,true,3)%>
										<%=fb.textBox("activo4",cdo.getColValue("activo4"),true,false,true,3)%>
										<%=fb.textBox("activo5",cdo.getColValue("activo5"),true,false,true,3)%>
										<%=fb.textBox("activo6",cdo.getColValue("activo6"),true,false,true,3)%>
										<%=fb.textBox("descActivo",cdo.getColValue("descActivo"),false,false,true,80)%>										
										<%=fb.button("btnactivo","...",true,false,null,null,"onClick=\"javascript:addCuenta('activos');\"")%>
									</td>
									<td width="10%" align="right">&nbsp;</td>
								</tr>					
							</table>
						</div>
					</td>
				</tr>
				<tr>
					<td id="Tusos" align="left" width="100%"  onClick="javascript:showHide(1)" style=" background-color:#770000; border-bottom:1.5pt solid #808080;" colspan="2">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr class="TextHeader">
				<td width="97%">&nbsp;<font color="#FFFFFF">Cuenta de Depreciaci&oacute;n Acumulada</font></td>
				<td width="3%" align="center" style="text-decoration:none; cursor:pointer;">
				[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;	</td>
			</tr>
		</table>
					</td>
				</tr>
				<tr>
					<td colspan="2">
					<div id="panel1" style="display:inline">
						<table width="100%" cellpadding="1" cellspacing="1" border="1" bordercolor="d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="90%">
									<%=fb.textBox("acumulada1",cdo.getColValue("acumulada1"),true,false,true,3)%>
									<%=fb.textBox("acumulada2",cdo.getColValue("acumulada2"),true,false,true,3)%>
									<%=fb.textBox("acumulada3",cdo.getColValue("acumulada3"),true,false,true,3)%>
									<%=fb.textBox("acumulada4",cdo.getColValue("acumulada4"),true,false,true,3)%>
									<%=fb.textBox("acumulada5",cdo.getColValue("acumulada5"),true,false,true,3)%>
									<%=fb.textBox("acumulada6",cdo.getColValue("acumulada6"),true,false,true,3)%>
									<%=fb.textBox("descAcum",cdo.getColValue("descAcum"),false,false,true,80)%>									
									<%=fb.button("btnacum","...",true,false,null,null,"onClick=\"javascript:addCuenta('depreAcum');\"")%></td>
									<td width="10%" align="right">&nbsp;</td>
									
							</tr>	
						</table>
					</div>
					</td>
				</tr>
				<!--<tr>
				<td id="Tequipo" align="left" width="100%"  onClick="javascript:showHide(2)" style=" background-color:#770000; border-bottom:1.5pt solid #808080;" colspan="2">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr class="TextHeader">
					<td width="97%">&nbsp;<font color="#FFFFFF">Cuenta de Gastos de Depreciaci&oacute;n</font></td>
					<td width="3%" align="center" style="text-decoration:none; cursor:pointer;" >
				[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;	</td>
				</tr>
			</table>
				</td>
				</tr>
				<tr>
				<td colspan="2">
					<div id="panel2" style="display:inline">
						<table width="100%" cellpadding="1" cellspacing="1" border="1" bordercolor="d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								
								<td width="90%"><%=fb.textBox("gasto1",cdo.getColValue("gasto1"),true,false,true,3)%>
							<%=fb.textBox("gasto2",cdo.getColValue("gasto2"),true,false,true,3)%>
							<%=fb.textBox("gasto3",cdo.getColValue("gasto3"),true,false,true,3)%>
							<%=fb.textBox("gasto4",cdo.getColValue("gasto4"),true,false,true,3)%>
							<%=fb.textBox("gasto5",cdo.getColValue("gasto5"),true,false,true,3)%>
							<%=fb.textBox("gasto6",cdo.getColValue("gasto6"),true,false,true,3)%>
							<%=fb.textBox("descDepre",cdo.getColValue("descDepre"),false,false,true,80)%>
							<%=fb.button("btngasto","...",true,false,null,null,"onClick=\"javascript:addCuenta('gastoDepre');\"")%></td>
							<td width="10%" align="right">&nbsp;</td>
							</tr>
						</table>
					</div>
				</td>
				</tr>-->
				<tr>
					<td id="TClasifi" align="left" width="100%"  onClick="javascript:showHide(3)" style=" background-color:#770000; border-bottom:1.5pt solid #808080;" colspan="2">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr class="TextHeader">
				<td width="97%">&nbsp;<font color="#FFFFFF">Clasificaci&oacute;n de Caracter&iacute;sticas</font></td>
				<td width="3%" align="center" style="text-decoration:none; cursor:pointer;">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;	</td>
			</tr>
		</table>
					</td>
				</tr>
				<tr>
					<td colspan="2">
					<div id="panel3" style="display:inline">
						<table width="100%" cellpadding="1" cellspacing="1" border="1" bordercolor="d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								
								<td width="90%"><%=fb.intBox("codehacienda",cdo.getColValue("codehacienda"),false,false,true,10)%>&nbsp;<%=fb.textBox("namehacienda",cdo.getColValue("namehacienda"),false,false,true,32)%><%=fb.button("btngasto","...",true,false,null,null,"onClick=\"javascript:hacienda();\"")%></td>
								<td width="10%" align="right">&nbsp;</td>
							</tr>	
						</table>
					</div>
					</td>
				</tr>
				<tr class="TextRow02">
		<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>
				<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
			<%=fb.formEnd(true)%>
			</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_especificacion");
 // cdo.addColValue("codigo_espec",request.getParameter("code"));
  cdo.addColValue("cta_control",request.getParameter("control")); 	
  cdo.addColValue("cta1_Activo",request.getParameter("activo1"));
  cdo.addColValue("cta2_activo",request.getParameter("activo2"));
  cdo.addColValue("cta3_activo",request.getParameter("activo3")); 	
  cdo.addColValue("cta4_activo",request.getParameter("activo4"));
  cdo.addColValue("cta5_activo",request.getParameter("activo5"));
  cdo.addColValue("cta6_activo",request.getParameter("activo6"));
  if (request.getParameter("acumulada1") != null)cdo.addColValue("cta1_depre_acum",request.getParameter("acumulada1"));
  if (request.getParameter("acumulada2") != null)cdo.addColValue("cta2_depre_acum",request.getParameter("acumulada2"));
  if (request.getParameter("acumulada3") != null)cdo.addColValue("cta3_depre_acum",request.getParameter("acumulada3"));
  if (request.getParameter("acumulada4") != null)cdo.addColValue("cta4_depre_acum",request.getParameter("acumulada4"));
  if (request.getParameter("acumulada5") != null)cdo.addColValue("cta5_depre_acum",request.getParameter("acumulada5"));
  if (request.getParameter("acumulada6") != null)cdo.addColValue("cta6_depre_acum",request.getParameter("acumulada6"));
  
  if (request.getParameter("gasto1") != null)cdo.addColValue("cta1_gast_depre",request.getParameter("gasto1"));
  if (request.getParameter("gasto2") != null)cdo.addColValue("cta2_gast_depre",request.getParameter("gasto2"));
  if (request.getParameter("gasto3") != null)cdo.addColValue("cta3_gast_depre",request.getParameter("gasto3"));
  if (request.getParameter("gasto4") != null)cdo.addColValue("cta4_gast_depre",request.getParameter("gasto4"));
  if (request.getParameter("gasto5") != null)cdo.addColValue("cta5_gast_depre",request.getParameter("gasto5"));
  if (request.getParameter("gasto6") != null)cdo.addColValue("cta6_gast_depre",request.getParameter("gasto6"));
  
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("saldo",request.getParameter("saldo"));
   if (request.getParameter("codehacienda") != null)
  cdo.addColValue("codigo_clasif",request.getParameter("codehacienda")); 
   
  if (mode.equalsIgnoreCase("add"))
  {
  	cdo.setAutoIncCol("codigo_espec");
 	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	SQLMgr.insert(cdo);
  }
  else
  {
	cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cta_control ="+request.getParameter("control")+" and codigo_espec="+request.getParameter("id"));
   //cdo.setWhereClause("codigo_espec="+request.getParameter("codigo"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/activos/grupo_activo_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/activos/grupo_activo_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/activos/grupo_activo_list.jsp';
<%
	}
%>
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