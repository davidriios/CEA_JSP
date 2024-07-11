<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String compania = ((String) session.getAttribute("_companyId"));
String mode = request.getParameter("mode");
String idOsetH1 = request.getParameter("oset_header1");
String idOsetH2 = request.getParameter("oset_header2");
String osetDetId = request.getParameter("oset_det_id");
String procedimiento = request.getParameter("procedimiento");
String type = request.getParameter("type");

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

if (idOsetH1 == null) idOsetH1 = "0";
if (idOsetH2 == null) idOsetH2 = "0";
if (osetDetId == null) osetDetId = "0";
if (type == null) type = "";
if (procedimiento == null) procedimiento = "";

if (mode == null) mode = "edit";

boolean viewMode = mode.equalsIgnoreCase("view");

CommonDataObject cdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET")) {
  
  String typeDsp = "OM MEDICAMENTOS";
  
  if(type.equalsIgnoreCase("RIS")) typeDsp = "OM RADIOLOGIA";
  else if(type.equalsIgnoreCase("LIS")) typeDsp = "OM LABORATORIO";
  else if(type.equalsIgnoreCase("BDS")) typeDsp = "BANCO DE SANGRE";

cdo = SQLMgr.getData("select frecuencia, dosis, observacion, PRIORIDAD, CONCENTRACION, FORMA, CANTIDAD, VIA, CENTRO_SERVICIO, nvl(ref_name, display_text) ref_name_dsp, motivo from TBL_OSET_HEADER2_DET where oset_header1 = "+idOsetH1+" and oset_header2 = "+idOsetH2+" and oset_det_id = "+osetDetId);
if (cdo == null) {
  cdo = new CommonDataObject();
}

ArrayList alForma = new ArrayList();
ArrayList alViaAd = new ArrayList();
ArrayList alCds = new ArrayList();
ArrayList alMotivo = new ArrayList();

if (type.equalsIgnoreCase("MED")) {
  alForma = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_grupo_dosis order by descripcion",CommonDataObject.class);
  alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where tipo_liquido='M' order by descripcion",CommonDataObject.class);
}
else if (type.equalsIgnoreCase("LIS") || type.equalsIgnoreCase("RIS")) {
  alCds = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio where reporta_a in(select codigo from tbl_cds_centro_servicio where interfaz = '"+type+"') and compania_unorg = "+compania, CommonDataObject.class);
}
else if (type.equalsIgnoreCase("BDS")) {
  alMotivo = sbb.getBeanList(ConMgr.getConnection(),"select z.codigo optValueColumn, z.descrip_motivo||'='||z.activa_observ optLabelColumn, z.codigo as optTitleColumn from tbl_sal_motivo_sol_proc z, tbl_cds_motivos_x_proc y where z.codigo = y.cod_motivo and y.cod_procedimiento = '"+procedimiento+"' and z.estado_motivo = 'A' and y.estado = 'A'", CommonDataObject.class);
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Configuración de Extra - '+document.title;
function doAction(){}
$(function() {});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("oset_header1", idOsetH1)%>
<%=fb.hidden("oset_header2", idOsetH2)%>
<%=fb.hidden("oset_det_id", osetDetId)%>
<%=fb.hidden("procedimiento", procedimiento)%>
<%=fb.hidden("type", type)%>

    <tr class="TextHeader">
      <td colspan="2">
        &nbsp;[<%=osetDetId%>]&nbsp;-&nbsp;[<%=typeDsp%>]&nbsp;
        <%=cdo.getColValue("ref_name_dsp")%>
      </td>
   </tr>
   
    <%if(type.equalsIgnoreCase("MED")) {%>
    <tr class="TextRow01">
      <td width="20%" align="right"><cellbytelabel>Frecuencia</cellbytelabel>:&nbsp;</td>
      <td width="80%"><%=fb.textBox("frecuencia",cdo.getColValue("frecuencia"),false,false,viewMode,50, 30, "",null,null)%></td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Dosis</cellbytelabel>:&nbsp;</td>
      <td><%=fb.textBox("dosis",cdo.getColValue("dosis"),false,false,viewMode,50, 30, "",null,null)%></td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Concentraci&oacute;n</cellbytelabel>:&nbsp;</td>
      <td><%=fb.textBox("concentracion",cdo.getColValue("concentracion"),false,false,viewMode,50, 100, "",null,null)%></td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Forma</cellbytelabel>:&nbsp;</td>
      <td>
      <%=fb.select("forma",alForma,cdo.getColValue("forma"),false,false,viewMode,0,"",null,null,"","S","")%>
      </td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>V&iacute;a</cellbytelabel>:&nbsp;</td>
      <td><%=fb.select("via",alViaAd,cdo.getColValue("via"),false,false,viewMode,0,"",null,null,"","S","")%></td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Cantidad</cellbytelabel>:&nbsp;</td>
      <td><%=fb.decBox("cantidad",cdo.getColValue("cantidad"),false,false,viewMode,50, 2, "",null,null)%></td>
    </tr>
    <%} else if (type.equalsIgnoreCase("LIS") || type.equalsIgnoreCase("RIS")){%>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Prioridad</cellbytelabel>:&nbsp;</td>
      <td>
        <label><input  type="radio" name="prioridad" id="prioridad" value="H"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("H")?" checked":""%>>Hoy</label>
        <label><input  type="radio" name="prioridad" id="prioridad" value="M"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("M")?" checked":""%>>Ma&ntilde;ana</label>
        <label><input  type="radio" name="prioridad" id="prioridad" value="U"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("U")?" checked":""%>>Urgente</label>
        <label><input  type="radio" name="prioridad" id="prioridad" value="O"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("O")?" checked":""%>>Otros</label>
      </td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Centro Servicio</cellbytelabel>:&nbsp;</td>
      <td>
        <%=fb.select("centro_servicio",alCds,cdo.getColValue("centro_servicio"),false,false,viewMode,0,"", null,null,"","S","")%>
      </td>
    </tr>
    
    <tr class="TextRow01">
      <td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel>:&nbsp;</td>
      <td>
        <%=fb.textarea("observacion", cdo.getColValue("observacion"), false, false, viewMode, 0, 1,500, "", "width:90%", "")%>
      </td>
    </tr>
            
    <%}else if (type.equalsIgnoreCase("BDS")){%>
		<tr class="TextRow01">
		  <td align="right"><cellbytelabel>Prioridad</cellbytelabel>:&nbsp;</td>
		  <td>
			<label><input  type="radio" name="prioridad" id="prioridad" value="U"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("U")?" checked":""%>>Transfundir Urgente(1HR - 1:30MIN)</label>
			<label><input  type="radio" name="prioridad" id="prioridad" value="H"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("H")?" checked":""%>>Transfundir Hoy(2-3 HR)</label>
			<label><input  type="radio" name="prioridad" id="prioridad" value="O"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("O")?" checked":""%>>Procedimiento Programado</label>
			<label><input  type="radio" name="prioridad" id="prioridad" value="P"<%=cdo.getColValue("prioridad"," ").equalsIgnoreCase("P")?" checked":""%>>Cruzar/Reservar PRN</label>
		  </td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Cantidad</cellbytelabel>:&nbsp;</td>
			<td>
				<%=fb.decBox("cantidad",cdo.getColValue("cantidad"),false,false,viewMode,10, 2, "",null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<cellbytelabel>Frecuencia</cellbytelabel>:&nbsp;
				<%=fb.textBox("frecuencia",cdo.getColValue("frecuencia"),false,false,viewMode,25, 30, "",null,null)%>
			</td>
		</tr>
		
		<tr class="TextRow01">
		  <td align="right"><cellbytelabel>Motivo</cellbytelabel>:&nbsp;</td>
		  <td>
			<%=fb.select("motivo",alMotivo,cdo.getColValue("motivo"),false,false,viewMode,0,"", null,null,"","S","")%>
		  </td>
		</tr>
    <%}%>
               
<tr class="TextRow02"><td colspan="2">&nbsp;</td></tr>
  <tr class="TextRow02">
    <td colspan="2" align="right">
      <%=fb.hidden("saveOption","O")%>
      <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"")%>
    </td>
  </tr>
  
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
    String saveOption = request.getParameter("saveOption");
    String baction = request.getParameter("baction");
        
    cdo = new CommonDataObject();
    cdo.setTableName("TBL_OSET_HEADER2_DET");
    
    if (type.equalsIgnoreCase("MED")) {
        cdo.addColValue("frecuencia", request.getParameter("frecuencia"));
        cdo.addColValue("dosis", request.getParameter("dosis"));
        cdo.addColValue("concentracion", request.getParameter("concentracion"));
        cdo.addColValue("forma", request.getParameter("forma"));
        cdo.addColValue("via", request.getParameter("via"));
        cdo.addColValue("cantidad", request.getParameter("cantidad"));
        
    } else if (type.equalsIgnoreCase("LIS") || type.equalsIgnoreCase("RIS")) {
       cdo.addColValue("prioridad", request.getParameter("prioridad"));
       cdo.addColValue("centro_servicio", request.getParameter("centro_servicio"));
       cdo.addColValue("observacion", request.getParameter("observacion"));
	   
    } else if (type.equalsIgnoreCase("BDS")) {
        cdo.addColValue("frecuencia", request.getParameter("frecuencia"));
        cdo.addColValue("cantidad", request.getParameter("cantidad"));
        cdo.addColValue("prioridad", request.getParameter("prioridad"));
        cdo.addColValue("motivo", request.getParameter("motivo"));
    }
    
    cdo.addColValue("modified_by",  (String)session.getAttribute("_userName"));
    cdo.addColValue("modified_date",  "sysdate");
    cdo.setWhereClause("oset_det_id = "+osetDetId+" and oset_header1 = "+idOsetH1+" and oset_header2 = "+idOsetH2);
    
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	 SQLMgr.update(cdo);
	ConMgr.clearAppCtx(null);
	
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
  alert("<%=SQLMgr.getErrMsg()%>");
	parent.hidePopWin();
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