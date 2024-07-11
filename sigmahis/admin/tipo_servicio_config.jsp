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
100031	VER LISTA DE TIPOS DE SERVICIOS
100033	AGREGAR TIPO DE SERVICIO
100034	MODIFICAR TIPO DE SERVICIO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
//CommonDataObject cdo= new CommonDataObject();

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
		if (id == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");

		sql = "select a.codigo as code, a.descripcion as name, a.cla_ser as cod ,a.compania, a.usado_x_res as usado, a.incremento, b.codigo as cod, b.descripcion as descp,a.clasif_cargo,(select b.descripcion from tbl_con_catalogo_gral b where a.cta1=b.CTA1 and a.cta2=b.CTA2 and a.cta3=b.CTA3 and a.cta4=b.CTA4 and a.cta5=b.cta5 and a.cta6=b.cta6 and b.compania=a.compania ) as cuentaName ,a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6 from tbl_cds_tipo_servicio a, tbl_cds_clasif_servicio b  where a.cla_ser=b.codigo and a.codigo="+id;
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipo de Servicio - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo de Servicio - Edición - "+document.title;
<%}%>
</script>
<script language="javascript">
function clasificacion()
{
abrir_ventana1('../admin/list_clasif_servicio.jsp');
}
function searchCuenta()
{ 
abrir_ventana1('../common/search_catalogo_gral.jsp?fp=tsCtas');
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TIPO SERVICIO"></jsp:param>
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
			<%=fb.hidden("code",cdo.getColValue("code"))%>
			<%=fb.hidden("usado",cdo.getColValue("usado"))%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel>Tipo de Servicio</cellbytelabel></td>
				</tr>	
				<tr class="TextRow01" >
					<td width="22%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="78%">&nbsp;<%=cdo.getColValue("code")%></td>
				
				</tr>							
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("name",cdo.getColValue("name"),true,false,false,56)%></td>
				</tr>		
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Clasificaci&oacute;n de Servicios</cellbytelabel></td>
					<td>&nbsp;<%=fb.intBox("cod",cdo.getColValue("cod"),true,false,true,10)%><%=fb.textBox("descp",cdo.getColValue("descp"),false,false,true,40)%><%=fb.button("clasif","...",true,false,null,null,"onClick=\"javascript:clasificacion();\"")%></td>
				</tr>			
					
				
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Clasificaci&oacute;n del Cargo</cellbytelabel></td>
					<td>&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo  as optValueColumn, codigo||' - '||descripcion as optLabelColumn   from tbl_cds_tipo_cargo_servicio order by codigo ","clasif_cargo",cdo.getColValue("clasif_cargo"),"")%>	</td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Incremento</cellbytelabel></td>
					<td>&nbsp;<%=fb.decBox("incremento",cdo.getColValue("incremento"),false,false,false,10, 13.2, "",null,"onFocus=\"this.select();\"","Incremento",false,"")%>/100
          </td>
				</tr> 
        <tr class="TextHeader">
          <td colspan="2">&nbsp;Cuenta para Costos De Cargos Distintos a articulos de Inventario</td>
        </tr>
        <tr class="TextRow01">
          <td>Cuenta De Costos</td>
          <td>
						<%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,3)%>
						<%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,3)%>
						<%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3)%>
						<%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3)%>
						<%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3)%>
						<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3)%>&nbsp;
						<%=fb.textBox("cuentaName",cdo.getColValue("cuentaName"),false,false,true,51)%>&nbsp;
						<%=fb.button("btnCta","...",true,false,null,null,"onClick=\"javascript:searchCuenta();\"")%>
					</td>
        </tr><!---->			
				<tr class="TextRow02">
					<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				</tr>	
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cds_tipo_servicio");
  cdo.addColValue("descripcion",request.getParameter("name")); 
  cdo.addColValue("clasif_cargo",request.getParameter("clasif_cargo")); 
  cdo.addColValue("cta1",request.getParameter("cta1"));
  cdo.addColValue("cta2",request.getParameter("cta2"));
  cdo.addColValue("cta3",request.getParameter("cta3"));
  cdo.addColValue("cta4",request.getParameter("cta4"));
  cdo.addColValue("cta5",request.getParameter("cta5"));
  cdo.addColValue("cta6",request.getParameter("cta6"));
  
	if(request.getParameter("incremento")!=null && !request.getParameter("incremento").equals("")) cdo.addColValue("incremento",request.getParameter("incremento")); 
  
	if (request.getParameter("cod") != null)
	cdo.addColValue("cla_ser",request.getParameter("cod"));
	cdo.addColValue("usado_x_res",request.getParameter("usado")); 
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncCol("codigo");

	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("code"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/tip_servicio_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/tip_servicio_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/tip_servicio_list.jsp';
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