
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
200001	VER LISTA DE ALMACENES
200003	AGREGAR ALMACEN
200004	MODIFICAR ALMACEN
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200003") || SecMgr.checkAccess(session.getId(),"200004"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String fp=request.getParameter("fp");
String date= CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String ctaInv= "N";
try {ctaInv =java.util.ResourceBundle.getBundle("issi").getString("ctaInv");}catch(Exception e){ ctaInv = "N";}

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")){
	if (mode.equalsIgnoreCase("add"))	{
		id = "0";
	}	else {
		if (id == null) throw new Exception("El Almacen no es válido. Por favor intente nuevamente!");

//sql = "select a.codigo_almacen as code, a.COMPANIA, a.descripcion as name, a.direccion , a.telefono, a.extension as ext, a.fax, a.cg_cta1 as cuentas1, a.cg_cta2 as cuentas2, a.cg_cta3 as cuentas3, a.cg_cta4 as cuentas4, a.cg_cta5 as cuentas5, a.cg_cta6 as cuentas6, a.usuario_creacion as usuarioC, a.usuario_modificacion as usuarioM, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha, to_char(a.fecha_modificacion, 'dd/mm/yyyy') as fmodific, b.cta1, b.cta2, b.cta3, b.cta4, b.cta5, b.cta6, c. cta1|| ' ' ||c.cta2|| ' ' ||c.cta3|| ' ' ||c.cta4|| ' ' ||c.cta5|| ' ' ||c.cta6 as cuentaName  from tbl_inv_almacen a, tbl_con_catalogo_gral b, tbl_con_catalogo_gral c where a.cg_cta1=b.CTA1 and a.CG_CTA2=b.CTA2 and a.cg_cta3=b.CTA3 and a.cg_cta4=b.CTA4 and a.cg_cta5=b.cta5 and a.cg_cta6=b.cta6 and a.cg_cta1=c.CTA1 and a.CG_CTA2=c.CTA2 and a.cg_cta3=c.CTA3 and a.cg_cta4=c.CTA4 and a.cg_cta5=c.cta5 and a.cg_cta6=c.cta6 and  a.codigo_almacen="+id;
sql="select a.codigo_almacen as code, a.COMPANIA, a.descripcion as name, a.direccion , a.telefono, a.extension as ext, a.fax, a.cg_cta1 as cuentas1,a.cg_cta2 as cuentas2, a.cg_cta3 as cuentas3,a.cg_cta4 as cuentas4,a.cg_cta5 as cuentas5,a.cg_cta6 as cuentas6, a.usuario_creacion as usuarioC, a.usuario_modificacion as usuarioM, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha, to_char(a.fecha_modificacion, 'dd/mm/yyyy') as fmodific ,(select b.descripcion from tbl_con_catalogo_gral b where a.cg_cta1=b.CTA1 and a.CG_CTA2=b.CTA2 and a.cg_cta3=b.CTA3 and a.cg_cta4=b.CTA4 and a.cg_cta5=b.cta5 and a.cg_cta6=b.cta6 and b.compania=a.compania ) as cuentaName  from tbl_inv_almacen a where a.codigo_almacen="+id+"  and a.compania = "+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
		
		if(ctaInv.trim().equals("N")){
		cdo.addColValue("cuentas1","");
		cdo.addColValue("cuentas2","");
		cdo.addColValue("cuentas3","");
		cdo.addColValue("cuentas4","");
		cdo.addColValue("cuentas5","");
		cdo.addColValue("cuentas6","");
		cdo.addColValue("cuentaName","");
		}
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
document.title="Almacenes - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Almacenes - Edición - "+document.title;
<%}%>
</script>
<script language="javascript">
function add()
{
abrir_ventana1('../common/search_catalogo_gral.jsp?fp=almacenCtas');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ALMACENES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("fp",fp)%>
        <tr>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="TextHeader">
          <td colspan="2" align="left">Identificaci&oacute;n del Almac&eacute;n</td>
        </tr>
        <tr class="TextRow01" >
          <td width="15%">C&oacute;digo</td>
          <td width="85%">
					<%=fb.intBox("codigo",id,false,mode.equals("edit"),true,5)%>
					<%=fb.textBox("name",cdo.getColValue("name"),true,false,false,40,80)%>
					</td>
        </tr>
        <tr class="TextHeader">
          <td colspan="2" class="">&nbsp;Generales de Almacenes</td>
        </tr>
        <tr>

          <td colspan="2"><table width="100%" cellpadding="0" cellspacing="1">
              <tr class="TextRow01">
                <td width="15%">Direcci&oacute;n</td>
                <td width="45%"><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,51,80)%></td>
                <td width="10%">Fax</td>
                <td width="30%"><%=fb.intBox("fax",cdo.getColValue("fax"),false,false,false,25,11)%></td>
				<!---- 25/05/2009  Nesby Solicita Cambio en tipo de datos, de valores alphanumericos a numericos para fax,telefono y extension  ---->
              </tr>
              <tr class="TextRow01">
                <td>Tel&eacute;fono</td>
                <td><%=fb.intBox("telefono",cdo.getColValue("telefono"),false,false,false,51,11)%></td>
                <td>Extensi&oacute;n</td>
                <td><%=fb.intBox("ext",cdo.getColValue("ext"),false,false,false,25,4)%></td>
              </tr>
            </table></td>
        </tr>
		<%if(ctaInv.trim().equals("S")){%>
        <tr class="TextHeader">
          <td colspan="2">&nbsp;Cuenta Financiera(Solo para ayuda en Mapping de ctas x Familia)</td>
        </tr>
        <tr class="TextRow01">
          <td>Cuenta</td>
          <td>
						<%=fb.textBox("cuentas1",cdo.getColValue("cuentas1"),false,false,true,3)%>
						<%=fb.textBox("cuentas2",cdo.getColValue("cuentas2"),false,false,true,3)%>
						<%=fb.textBox("cuentas3",cdo.getColValue("cuentas3"),false,false,true,3)%>
						<%=fb.textBox("cuentas4",cdo.getColValue("cuentas4"),false,false,true,3)%>
						<%=fb.textBox("cuentas5",cdo.getColValue("cuentas5"),false,false,true,3)%>
						<%=fb.textBox("cuentas6",cdo.getColValue("cuentas6"),false,false,true,3)%>&nbsp;
						<%=fb.textBox("cuentaName",cdo.getColValue("cuentaName"),false,false,true,51)%>&nbsp;
						<%=fb.button("cancel","...",true,false,null,null,"onClick=\"javascript:add();\"")%>
					</td>
        </tr><%}%><!---->
        <tr class="TextRow02">
          <td colspan="2" align="right">
					<%=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
        </tr>
        <tr>
          <td colspan="2">&nbsp;</td>
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_inv_almacen");
	cdo.addColValue("descripcion",request.getParameter("name"));
  cdo.addColValue("direccion",request.getParameter("direccion"));
	cdo.addColValue("telefono",request.getParameter("telefono"));
  cdo.addColValue("extension",request.getParameter("ext"));
	cdo.addColValue("fax",request.getParameter("fax"));
  if(request.getParameter("cuentas1")==null)cdo.addColValue("cg_cta1","");
  else cdo.addColValue("cg_cta1",request.getParameter("cuentas1"));
  if(request.getParameter("cuentas2")==null)cdo.addColValue("cg_cta2","");
  else cdo.addColValue("cg_cta2",request.getParameter("cuentas2"));
  if(request.getParameter("cuentas3")==null)cdo.addColValue("cg_cta3","");
  else cdo.addColValue("cg_cta3",request.getParameter("cuentas3"));
  cdo.addColValue("cg_cta4","");
  cdo.addColValue("cg_cta5","");
  cdo.addColValue("cg_cta6","");
  /*if(request.getParameter("cuentas4")==null)cdo.addColValue("cg_cta4","");
  else cdo.addColValue("cg_cta4",request.getParameter("cuentas4"));
  if(request.getParameter("cuentas5")==null)cdo.addColValue("cg_cta5","");
  else cdo.addColValue("cg_cta5",request.getParameter("cuentas5"));
  if(request.getParameter("cuentas6")==null)cdo.addColValue("cg_cta6","");
  else cdo.addColValue("cg_cta6",request.getParameter("cuentas6"));	*/
	
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

	cdo.setCreateXML(true);
	cdo.setFileName("almacenes.xml");
	cdo.setOptValueColumn("codigo_almacen");
	cdo.setOptLabelColumn("codigo_almacen||' - '||descripcion");
	cdo.setKeyColumn("compania");
	cdo.setXmlOrderBy("codigo_almacen");
	cdo.setXmlWhereClause("");


  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncCol("codigo_almacen");

	SQLMgr.insert(cdo);
  }
  else
  {
     cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and codigo_almacen="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/almacenes_list.jsp?fp="+fp))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/almacenes_list.jsp")%>?fp=<%=fp%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/almacenes_list.jsp?fp=<%=fp%>';
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
