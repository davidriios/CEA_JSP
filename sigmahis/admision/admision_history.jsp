<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

//SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");

if (mode == null) mode = "add";
if (fp == null) fp = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (pacId != null )
	{
		sql = " select aa.pac_id, aa.secuencia, to_char(aa.fecha_ingreso, 'dd-mm-yyyy') as fingreso, to_char(aa.fecha_egreso, 'dd-mm-yyyy') as fegreso, cds.descripcion as centroAdm, substr(cat.descripcion, 1, 3) as categoriaAdm, t.descripcion as tipoAdm, (select nombre_abreviado from tbl_adm_empresa e,tbl_adm_beneficios_x_admision aba  where aba.pac_id = aa.pac_id and aba.admision = aa.secuencia and e.codigo = aba.empresa and e.estado = 'A' and aba.prioridad = 1 and nvl(aba.estado, 'A') = 'A' and rownum=1) nombreAseg, decode(aa.conta_cred, 'C', 'CO', 'R', 'CR') cocr, aa.corte_cta, decode(aa.tipo_cta, 'J', 'JUBILADO', 'P', 'PARTICULAR', 'M', 'MEDICO', 'E', 'EMPLEADO', 'A', 'ASEGURADO', '---') tipoCta,       decode(aa.estado, 'A', 'ACTIVO', 'E', 'ESPERA', 'S', 'ESPECIAL', 'C', 'CANCELADA', 'N', 'ANULADA', 'T', 'TEMPORAL', 'P', 'PRE-ADM', 'I', 'INACTIVA') estadoAdm, nvl(getFacturaEmpresa(aa.pac_id, aa.secuencia, aa.compania),' ') as facEmp, nvl(getFacturaPaciente(aa.pac_id, aa.secuencia, aa.compania),' ') as factPacte  from tbl_adm_admision aa, tbl_cds_centro_servicio cds, tbl_adm_categoria_admision cat, tbl_adm_tipo_admision_cia t where aa.centro_servicio = cds.codigo and aa.categoria = cat.codigo  and aa.tipo_admision = t.codigo  and aa.categoria = t.categoria  and aa.pac_id = "+pacId+" and aa.compania = "+(String) session.getAttribute("_companyId")+" order by aa.secuencia ";
		//sql = "select a.secuencia as noAdmision, to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am') as fechaIngreso, a.categoria, a.tipo_admision as tipoAdmision, c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, b.cds as centroServicio, z.descripcion as centroServicioDesc from tbl_adm_admision a, tbl_adm_atencion_cu b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, tbl_cds_centro_servicio z where a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and b.cds=z.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia!="+noAdmision+" order by a.secuencia desc";
		//System.out.println("SQL:\n"+sql);
		al = SQLMgr.getDataList(sql);//sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Historial de Admisiones - "+document.title;

function openAdmision(noAdmision)
{
	parent.window.location='../admision/consulta_general.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" class="TextRow01">
<table width="100%" cellpadding="1" cellspacing="1">
<tr class="TextHeader" align="center">
  <td width="3%">Adm.</td>
  <td width="7%">Ingreso</td>
  <td width="7%">Egreso</td>
  <td width="5%">Categ.</td>
  <td width="16%">Area Adm.</td>
  <td width="8%">Tipo Pac.</td>
  <td width="5%">CO/CR</td>
  <td width="7%">Estado</td>
  <td width="7%">Aseg.</td>
  <td width="7%">Fac.Pac</td>
  <td width="7%">Fac.Emp</td>
</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);  //Admision adm = (Admision) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

%>
<tr class="<%=color%>" onClick="javascript:openAdmision(<%=cdo.getColValue("secuencia")%>)" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
  <td align="center" class="Text11"><%=cdo.getColValue("secuencia")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("fingreso")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("fegreso")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("categoriaAdm")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("centroAdm")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("tipoCta")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("cocr")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("estadoAdm")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("nombreAseg")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("factPacte")%></td>
  <td align="center" class="Text11"><%=cdo.getColValue("facEmp")%></td>
</tr>
<%
}
if (al.size() == 0)
{
%>
<tr class="TextRow03">
  <td colspan="11" align="center">No existen admisiones anteriores!!</td>
</tr>
<%
}
%>
</table>
</body>
</html>
<%
}//GET
%>