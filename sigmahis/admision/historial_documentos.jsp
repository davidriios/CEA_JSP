<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";

if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("No podemos encontrar ese paciente.");

if (request.getMethod().equalsIgnoreCase("GET")) {
  SQL2BeanBuilder sbb = new SQL2BeanBuilder();
  Admision adm = new Admision();
  
  StringBuffer sbSql = new StringBuffer();
	sbSql.append("select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_paciente where pac_id=a.pac_id) as nombrePaciente, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id=a.pac_id) as fechaNacimientoAnt, a.pac_id as pacId from tbl_adm_admision a where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(), sbSql.toString(), Admision.class);
  
  ArrayList al = SQLMgr.getDataList("select d.codigo, d.nombre, decode(e.scanpath,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("scanned").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"), request.getContextPath())+"/'||e.scanpath) as scanPath, nvl(e.scanpath,'') title ,decode(e.scanpath,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("scanned")+"/'||e.scanpath) as filePath, e.secuencia as admision, decode(d.area_revision, 'AD','ADMISION', 'AM', 'SALAS') area_revision from tbl_adm_documento d, TBL_ADM_DOC_ESCANEADO e where /*.area_revision IN ('AD','AM') and*/ e.pacid = "+pacId+" and e.secuencia <> "+noAdmision+" and d.codigo = e.docid order by e.secuencia, d.codigo");

%>

<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>

</script>

</head>
<body>

<table align="center" width="100%" cellpadding="0" cellspacing="1">

  <tr class="TextRow02"><td align="right">&nbsp;</td></tr>
  <tr class="TextPanel">
    <td>Historial de Documentos</td>
  </tr>

  <tr>
      <td align="center">
          <table width="90%" cellpadding="1" cellspacing="1">
          <tr class="TextRow01">
            <td width="15%" align="right"><cellbytelabel id="2">Fecha de Admisi&oacute;n</cellbytelabel></td>
            <td width="35%"><%=adm.getFechaIngreso()%></td>
            <td width="15%" align="right"><cellbytelabel id="3">No. Admisi&oacute;n</cellbytelabel></td>
            <td width="35%"><%=adm.getNoAdmision()%></td>
          </tr>
          <tr class="TextRow01">
            <td align="right"><cellbytelabel id="4">Fecha de Nacimiento</cellbytelabel></td>
            <td><%=adm.getFechaNacimientoAnt()%></td>
            <td align="right"><cellbytelabel id="5">No. Paciente</cellbytelabel></td>
            <td><%=adm.getCodigoPaciente()%></td>
          </tr>
          <tr class="TextRow01">
            <td align="right"><cellbytelabel id="6">Paciente</cellbytelabel></td>
            <td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
          </tr>
          </table>
      </td>
	</tr>
	
	 <tr>
      <td align="center">
          <table width="90%" cellpadding="1" cellspacing="1">
            <tr class="TextHeader">
              <td width="15%"><cellbytelabel id="2">&Aacute;rea</cellbytelabel></td>
              <td width="50%">Descripci&oacute;n</td>
              <td width="35%"><cellbytelabel id="3">Archivo</cellbytelabel></td>
            </tr>
            
            <%
              String gAdm = "";
              
              for (int i = 0; i < al.size(); i++) {
                 CommonDataObject cdo = (CommonDataObject) al.get(i);
                 String color = "TextRow02";
                 if (i % 2 == 0) color = "TextRow01";
                 
                 if (!gAdm.equals(cdo.getColValue("admision"))) { %>
                    <tr class="TextHeader02">
                      <td colspan="3">Admis&iacute;n #<%=cdo.getColValue("admision")%></td>
                    </tr>
                 <%}%>
                    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
                      <td><%=cdo.getColValue("area_revision")%></td>
                      <td>[<%=cdo.getColValue("codigo")%>] <%=cdo.getColValue("nombre")%></td>
                      <td>
                        <a href="javascript:abrir_ventana('<%=cdo.getColValue("scanPath")%>')" class="Link02Bold"><%=cdo.getColValue("title")%></a>
                       </td>
                    </tr>
                 <%
                 gAdm = cdo.getColValue("admision");
              } // for i
            
            %>
          
          </table>
      </td>
	</tr>






















</table>

</body>
</html>
<%}%>
