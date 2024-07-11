
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

int rowCount = 0;
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String compania =  (String) session.getAttribute("_companyId");	



if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	
	
	
	sql = "select a.anio, a.categoria, a.aseguradora, a.usuario, a.numero_lista lista, to_char(a.fecha,'dd/mm/yyyy')fecha, a.estado ,(select descripcion from tbl_adm_categoria_admision where codigo= a.categoria) descCategoria,(select nombre from tbl_adm_empresa where codigo = a.aseguradora)descEmpresa from tbl_fac_lista_envio_parametros a where upper(a.usuario) = upper('tirza') and a.estado  = 'I'";
	al= SQLMgr.getDataList(sql);
	sql = "select a.anio, a.categoria, a.aseguradora, a.usuario, a.numero_lista lista, to_char(a.fecha,'dd/mm/yyyy')fecha, a.estado ,(select descripcion from tbl_adm_categoria_admision where codigo= a.categoria) descCategoria,(select nombre from tbl_adm_empresa where codigo = a.aseguradora)descEmpresa from tbl_fac_lista_envio_parametros a where upper(a.usuario) = upper('tirza') and a.estado  = 'A'";
	al2= SQLMgr.getDataList(sql);
	/*"+session.getAttribute("_userName")+"*/
	
	//al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	//rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function printList()
{
	//abrir_ventana('../inventario/print_list_sol_mat_pac.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=RSP');
}
function existsList()
{
	var size = document.form1.al2Size.value;
	if(size==0)return false;
	else return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACIÓN - INACTIVAR LISTAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
		<%=fb.hidden("al1Size",""+al.size())%>
		<%=fb.hidden("al2Size",""+al2.size())%>
		<%fb.appendJsValidation("if(!existsList()){CBMSG.warning('No Hay Lista para Inactivar!');error++;}");%>

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		
		<tr class="TextHeader" align="center">
		<td colspan="7"><cellbytelabel>LISTAS DE ENV&Iacute;OS INACTIVAS</cellbytelabel></td>
		</tr>
		<!----><tr class="TextRow01">
		<td colspan="7">
		<div id="ListadaInactivas" width="100%" style="overflow:scroll;position:relative;height:300">
		<div id="detLista" width="100%" style="overflow;position:absolute">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="4%"><cellbytelabel>Usuario</cellbytelabel></td>
			<td width="6%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Categor&iacute;</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Aseguradora</cellbytelabel></td>
			<td width="10%"><cellbytelabel>No. Lista</cellbytelabel></td>
			<td width="10%"><cellbytelabel>F. Creaci&oacute;n</cellbytelabel></td>
			<td width="20%"><cellbytelabel>Estado</cellbytelabel></td>
			
		</tr>
		
		
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=fb.textBox("xusuario"+i,cdo.getColValue("usuario"),false,false,true,10)%></td>
			<td align="center"><%=fb.textBox("xanio"+i,cdo.getColValue("anio"),false,false,true,5)%></td>
			<td align="center"><%=fb.textBox("xcategoria"+i,cdo.getColValue("categoria"),false,false,true,3)%>
							   <%=fb.textBox("xdescCategoria"+i,cdo.getColValue("descCategoria"),false,false,true,15)%></td>
			<td align="center"><%=fb.textBox("xaseguradora"+i,cdo.getColValue("aseguradora"),false,false,true,5)%> 
							   <%=fb.textBox("xdescEmpresa"+i,cdo.getColValue("descEmpresa"),false,false,true,15)%></td>
			<td align="center"><%=fb.textBox("xlista"+i,cdo.getColValue("lista"),false,false,true,5)%></td>
			<td align="left"><%=fb.textBox("xfechaCreacion"+i,cdo.getColValue("fecha"),false,false,true,10)%></td>
			<td align="center"><%=fb.select("xestado"+i,"A=ACTIVA,I=INACTIVA",cdo.getColValue("estado"),false,true,0,"",null,"onChange=\"javascript:puEstado(this)\"",null,"")%>
				
			</td>
			
		</tr>
<%
}
%>
			</table>
			</div>
			</div>
	     </td>
		</tr>

<tr class="TextHeader" align="center">
		<td colspan="7"><cellbytelabel>LISTAS DE ENV&Iacute;OS ACTIVAS</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
		<td colspan="7">
		<div id="ListadaInactivas" width="100%" style="overflow:scroll;position:relative;height:300">
		<div id="detLista" width="100%" style="overflow;position:absolute">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		
		<tr class="TextHeader" align="center">
			<td width="14%"><cellbytelabel>Usuario</cellbytelabel></td>
			<td width="6%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Aseguradora</cellbytelabel></td>
			<td width="10%"><cellbytelabel>No. Lista</cellbytelabel></td>
			<td width="10%"><cellbytelabel>F. Creaci&oacute;n</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Estado</cellbytelabel></td>
			
		</tr>
		
		
<%
for (int j=0; j<al2.size(); j++)
{
	CommonDataObject cdo = (CommonDataObject) al2.get(j);
	String color = "TextRow02";
	if (j % 2 == 0) color = "TextRow01";
	
%>
		<%//=fb.hidden("anio"+j,cdo.getColValue("anio"))%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=fb.textBox("usuario"+j, cdo.getColValue("usuario"),false,false,true,10)%></td>
			<td align="center"><%=fb.textBox("anio"+j, cdo.getColValue("anio"),false,false,true,5)%></td>
			<td align="center"><%=fb.textBox("categoria"+j, cdo.getColValue("categoria"),false,false,true,3)%>
							   <%=fb.textBox("descCategoria"+j, cdo.getColValue("descCategoria"),false,false,true,15)%></td>
			<td align="center"><%=fb.textBox("aseguradora"+j, cdo.getColValue("aseguradora"),false,false,true,5)%> 
							   <%=fb.textBox("descEmpresa"+j, cdo.getColValue("descEmpresa"),false,false,true,15)%></td>
			<td align="center"><%=fb.textBox("lista"+j, cdo.getColValue("lista"),false,false,true,5)%></td>
			<td align="left"><%=fb.textBox("fecha"+j, cdo.getColValue("fecha"),false,false,true,10)%></td>
			<td align="center"><%=fb.select("estado"+j,"A=ACTIVA,I=INACTIVA",cdo.getColValue("estado"),false,false,0,"",null,"",null,"")%>
				
			</td>
			
		</tr>
<%
}
%>
				</table>
			</div>
			</div>
	     </td>
		</tr>

<tr class="TextRow02">
          <td colspan="7" align="right"><%=fb.submit("save","Guardar",true,false)%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
		</table>
<%=fb.formEnd()%>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%}
//End Method GET 
else 
{ // Post
ArrayList alx= new ArrayList();
 int size =Integer.parseInt(request.getParameter("al2Size"));
 System.out.println("size == "+size);
 for(int z=0;z<size;z++)
 {
			
  if (request.getParameter("estado"+z) != null && !request.getParameter("estado"+z).equals("") && request.getParameter("estado"+z).trim().equals("I"))
  {
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_fac_lista_envio_parametros"); 
			cdo.setWhereClause("anio="+request.getParameter("anio"+z)+" and categoria="+request.getParameter("categoria"+z)+" and aseguradora = "+request.getParameter("aseguradora"+z)+" and numero_lista="+request.getParameter("lista"+z));
			//cdo.setWhereClause(" upper(usuario) = upper('tirza') and estado= 'A' ");

			System.out.println("anio == "+request.getParameter("anio"+z));
			System.out.println("numero_lista == "+request.getParameter("lista"+z));
			System.out.println("categoria == "+request.getParameter("categoria"+z));
			System.out.println("aseguradora == "+request.getParameter("aseguradora"+z));
			System.out.println("estado == "+request.getParameter("estado"+z));
			
			cdo.addColValue("anio",request.getParameter("anio"+z));
			cdo.addColValue("usuario",request.getParameter("usuario"+z));
			cdo.addColValue("numero_lista",request.getParameter("lista"+z));
			cdo.addColValue("categoria",request.getParameter("categoria"+z));
			cdo.addColValue("fecha",request.getParameter("fecha"+z));
			cdo.addColValue("aseguradora",request.getParameter("aseguradora"+z));
			cdo.addColValue("estado",request.getParameter("estado"+z));
			//cdo.addColValue("noSolicitud",request.getParameter("noSolicitud"+z));
			//cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
 		  alx.add(cdo);
	}
	
	}  
	if (alx.size() == 0)
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_fac_lista_envio_parametros");
		cdo.setWhereClause(" upper(usuario) = upper('"+session.getAttribute("_userName")+"') and estado= 'A' ");
		alx.add(cdo);
	}
	
	//SQLMgr.insertList(al1);
	SQLMgr.updateList(alx);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
  alert('<%=SQLMgr.getErrMsg()%>');
<%
  if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/list_inactivar_lista.jsp")){
%>
  //window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_rechazar_sol_pac.jsp")%>';
<%
  } else {
%>
  window.location = '<%=request.getContextPath()%>/facturacion/list_inactivar_lista.jsp';
<%
  }
%>
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
