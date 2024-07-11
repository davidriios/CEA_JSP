<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = "";
String primerNombre = "", primerApellido = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha = ( request.getParameter("fecha") == null?"":request.getParameter("fecha") );
String cdsFrom = ( request.getParameter("cdsFrom") == null?"":request.getParameter("cdsFrom") );
String cdsTo = ( request.getParameter("cdsTo") == null?"":request.getParameter("cdsTo") );
String estado = ( request.getParameter("estado") == null?"":request.getParameter("estado") );

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
  {
    appendFilter += " and trunc(s.fecha_ini_sol) = to_date('"+request.getParameter("fecha")+"','dd/mm/yyyy')";
  }
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
  {
    appendFilter += " and s.estado = '"+request.getParameter("estado").toUpperCase()+"'";
  }
  if (request.getParameter("cdsFrom") != null && !request.getParameter("cdsFrom").trim().equals(""))
  {
    appendFilter += " and s.del_cds in( "+request.getParameter("cdsFrom")+" )";
  }
  if (request.getParameter("cdsTo") != null && !request.getParameter("cdsTo").trim().equals(""))
  {
    appendFilter += " and s.al_cds in ( "+request.getParameter("cdsTo")+" )";
  }

  sql = "select /*<SOL>*/ s.id id_sol, s.escolta_id, s.pac_id, s.admision, s.del_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.del_cds and rownum = 1) del_cds_dsp,  s.al_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.al_cds and rownum = 1) al_cds_dsp, s.cama_origen, s.cama_destino, s.observacion, to_char(s.fecha_ini_sol,'dd/mm/yyyy') f_ini_sol, to_char(s.fecha_fin_sol,'dd/mm/yyyy') f_fin_sol, s.usuario_creacion, to_char(s.fecha_creacion,'dd/mm/yyyy') f_crea, to_char(s.fecha_modificacion,'dd/mm/yyyy') f_mod, s.usuario_modificacion, s.estado, s.cat_admision, s.observ/*</SOL>*/ , /*<PAC>*/ p.nombre_paciente, p.id_paciente ced_pac /*</PAC>*/  ,/*<ESC>*/  decode(e.emp_id,null,'EXT','INT') tipo_esc, e.id id_esc, e.primer_nombre||' '||e.segundo_nombre||' '||e.primer_apellido||' '||e.segundo_apellido nombre_esc , coalesce(e.pasaporte,decode (e.provincia, 0, '', 00, '', e.provincia)|| decode (e.sigla, '00', '', '0', '', e.sigla)|| '-'|| e.tomo|| '-'|| e.asiento) ced_esc, e.emp_id /*</ESC>*/ from tbl_sal_sol_escolta s, vw_adm_paciente p, tbl_adm_admision a, tbl_adm_escolta e where s.pac_id = p.pac_id and p.pac_id = a.pac_id and s.admision = a.secuencia and a.pac_id = s.pac_id and s.escolta_id = e.id /*<FILTRO>*/ "+appendFilter+" /*</FILTRO>*/";

  al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Escolta - '+document.title;

function updateSolStatus(ind){
	document.getElementById("currentIndex").value  = ind;
	document.getElementById("currentUrl").value  = window.location.href;
	var solId = document.getElementById("solId"+ind).value;
	var curStatus = document.getElementById("estado"+ind).value;
	if (canSubmit(solId,curStatus)) document.form0.submit();
}

function canSubmit(sol,curStatus){
   if( hasDBData('<%=request.getContextPath()%>','tbl_sal_sol_escolta','estado=\'E\' and id=\''+sol+'\'','') && curStatus=='E' ){
      alert("Esta solicitud ya esta ejecutando!");
      return false;
   }else
   if( hasDBData('<%=request.getContextPath()%>','tbl_sal_sol_escolta','estado=\'E\' and id=\''+sol+'\'','') && curStatus=='C' ){
      alert("Esta solicitud ya no puede ser ser cancelada!");
      return false;
   }
   return true;
}

function changeEscort(id, pacId, noAdmision,fromCDS,fromBed,cdsAdmDesc,admCategory,oldEscortId,toCdsDesc){
   abrir_ventana('../admision/reg_sol_escolta.jsp?mode=edit&id='+id+'&pacId='+pacId+'&noAdmision='+noAdmision+'&fromCDS='+fromCDS+'&fromBed='+fromBed+'&cdsAdmDesc='+cdsAdmDesc+'&admCategory='+admCategory+'&oldEscortId='+oldEscortId+'&toCdsDesc='+toCdsDesc);
}

function setCurrentIndex(){
	var size = "<%=al.size()%>";
	for (i=0; i<size;i++){
		if (document.getElementById("check").checked){
			alert(document.getElementById("escortId"+i).value);
		}else{alert("Nope");}
	}
}
function doAction(){
	//timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','parent._parentReload()');
    parent.getSol('<%=al.size()%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder TableBottomBorder TableTopBorder">

			<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("currentIndex","")%>
				<%=fb.hidden("currentUrl","")%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("cdsFrom",cdsFrom)%>
				<%=fb.hidden("cdsTo",cdsTo)%>
				<%=fb.hidden("estado",estado)%>

				<tr><td colspan="8"><label id="timerMsgTop"></label></td></tr>

			<tr class="TextHeader">
				<td width="18%">Nombre Paciente</td>
				<td width="8%" align="center">PID - ADM.</td>
				<td width="10%" align="center">C&eacute;dula</td>
				<td width="15%">&Aacute;rea Actual</td>
				<td width="8%" align="center">Cama Actual</td>
				<td width="15%">&Aacute;rea Destino</td>
				<td width="8%" align="center">Cama Destino</td>
				<td width="18%" align="center">Acciones</td>
			</tr>
			<%
				String escortId = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";

				 if ( !escortId.equals("escolta_id") ) {
			 %>
					<tr class="TextHeader02">
						<td align="right">Escolta:&nbsp;&nbsp;&nbsp;</td>
						<td colspan="7"><%=cdo.getColValue("nombre_esc")%> [<%=cdo.getColValue("escolta_id")%>] [<%=cdo.getColValue("ced_esc")%>]
						</td>
					</tr>
			    <% } %>

  				<%=fb.hidden("escortId"+i,cdo.getColValue("escolta_id"))%>
  				<%=fb.hidden("solId"+i,cdo.getColValue("id_sol"))%>
  				<%=fb.hidden("toCdsDesc"+i,cdo.getColValue("al_cds_dsp"))%>

			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td><%=cdo.getColValue("nombre_paciente")%></td>
				<td align="center"><%=cdo.getColValue("pac_id")+" - "+cdo.getColValue("admision")%></td>
				<td align="center"><%=cdo.getColValue("ced_pac")%></td>
				<td>[<%=cdo.getColValue("del_cds")%>] <%=cdo.getColValue("del_cds_dsp")%></td>
				<td align="center"><%=cdo.getColValue("cama_origen")%></td>
				<% if ( !cdo.getColValue("al_cds").trim().equals("") ) {%>
					<td>[<%=cdo.getColValue("al_cds")%>] <%=cdo.getColValue("al_cds_dsp")%></td>
					<td align="center"><%=cdo.getColValue("cama_destino")%></td>
				<%}else{%>
				   <td colspan="2">[N/A]: <%=cdo.getColValue("observacion")%></td>
				<%}%>
				<td align="right">
					<%=fb.select("estado"+i,"E=EJECUTAR,F=FINALIZAR,C=CANCELAR",cdo.getColValue("estado"),false,(cdo.getColValue("estado").trim().equals("C") || cdo.getColValue("estado").trim().equals("F")),0,"",null,"")%>

					<% if ( cdo.getColValue("estado").trim().equals("P") || cdo.getColValue("estado").trim().equals("E") ) {%>
						<img src="../images/ok.gif" alt="Procesar" title="Procesar" onClick="javascript:updateSolStatus('<%=i%>')" style="cursor:pointer" width="20px" height="20px">
					<%if (cdo.getColValue("estado").trim().equals("P")){%>
					   <img src="../images/edit.png" alt="Procesar" title="Cambiar Escolta" onClick="javascript:changeEscort('<%=cdo.getColValue("id_sol")%>','<%=cdo.getColValue("pac_id")%>','<%=cdo.getColValue("admision")%>','<%=cdo.getColValue("del_cds")%>','<%=cdo.getColValue("cama_origen")%>','<%=cdo.getColValue("del_cds_dsp")%>','<%=cdo.getColValue("cat_admision")%>','<%=cdo.getColValue("escolta_id")%>','<%=cdo.getColValue("al_cds_dsp")%>')" style="cursor:pointer" width="20px" height="20px">
					<%}}else{%>
					    <img src="../images/readonly.png" alt="No esta pendiente" width="20px" height="20px">
					<%}%>
					<img src="../images/print_analysis.gif" alt="Imprimir orden" width="20px" height="20px" style="cursor:pointer" onClick="javascript:parent.printReport('<%=cdo.getColValue("id_sol")%>')">
				</td>
			</tr>
			<% if (!cdo.getColValue("observ").trim().equals("")){%>

				<tr class="<%=color%>">
					<td>Observaci&oacute;n</td>
					<td colspan="7">
						<%=fb.textarea("observ",cdo.getColValue("observ"),false,false,true,50,2,0)%>
					</td>
				</tr>

			<%
		    }
			escortId = cdo.getColValue("escolta_id");
			}
			%>
			<tr class="TextRow02">
				<td align="right" colspan="8">
					<%//=fb.button("send","Procesar",true,false,null,null,"onClick=\"javascript:_doSubmit()\"")%>
				</td>
			</tr>
			<%=fb.formEnd(true)%>
		</table>
		</td>

	</tr>
</table>
</body>
</html>
<%
}else{

	CommonDataObject cdoSolEscort = new CommonDataObject();
	String currentIndex = ( request.getParameter("currentIndex")==null?"":request.getParameter("currentIndex") );
	String solId = "";

  	cdoSolEscort.setTableName("tbl_sal_sol_escolta");

  	if ( request.getParameter("estado"+currentIndex) != null ){
		cdoSolEscort.addColValue("estado",request.getParameter("estado"+currentIndex));

	  	cdoSolEscort.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdoSolEscort.addColValue("fecha_modificacion",cDate);

		if (request.getParameter("estado"+currentIndex).trim().equals("F")){
			cdoSolEscort.addColValue("fecha_fin_sol",cDate);
	    }

		if (!currentIndex.trim().equals("")){
			solId = request.getParameter("solId"+currentIndex);
		}

	  	cdoSolEscort.setWhereClause("id = "+solId);
    }else{
        cdoSolEscort = new CommonDataObject();
        cdoSolEscort.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
    	cdoSolEscort.setWhereClause("id = -1");
    }

    SQLMgr.update(cdoSolEscort);
	//System.out.println("thebrain> this a message from POST................................................."+solId);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
//	../expediente/

String currentUrl = (request.getParameter("currentUrl")==null?request.getContextPath()+"/expediente/sol_escolta_det.jsp?fecha="+request.getParameter("fecha")+"&cdsFrom="+request.getParameter("cdsFrom")+"&cdsTo="+request.getParameter("cdsTo")+"&fg=&estado="+request.getParameter("estado"):request.getParameter("currentUrl"));

if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	var currentUrl = "<%=currentUrl%>";
    currentUrl = currentUrl.split("&estado=");
    currentUrl = currentUrl[0]+'&estado=<%=request.getParameter("estado"+currentIndex)%>';
	window.location = currentUrl;
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