<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.escolta.SolEscolta"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="SolEscMgr" scope="page" class="issi.escolta.SolEscoltaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CommonDataObject escSolCdo = new CommonDataObject();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SolEscMgr.setConnection(ConMgr);

SolEscolta so = new SolEscolta();

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
String sql = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String pacId = (request.getParameter("pacId")==null?"":request.getParameter("pacId"));
String noAdmision = (request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision"));
String fromBed = (request.getParameter("fromBed")==null?"":request.getParameter("fromBed"));
String fromCDS = (request.getParameter("fromCDS")==null?"":request.getParameter("fromCDS"));
String cdsAdmDesc = (request.getParameter("cdsAdmDesc")==null?"":request.getParameter("cdsAdmDesc"));
String admCategory = (request.getParameter("admCategory")==null?"":request.getParameter("admCategory"));
String toCdsDesc = ( request.getParameter("toCdsDesc") == null?"":request.getParameter("toCdsDesc") );

CommonDataObject cdoNextId = SQLMgr.getData("select nvl(max(id),0)+1 next_id from tbl_esc_sol_escolta");
String nextId = cdoNextId.getColValue("next_id");

if (cdsAdmDesc.trim().equals("")){
  CommonDataObject cdoA = SQLMgr.getData("select descripcion cds_adm_desc from tbl_cds_centro_servicio where codigo = "+fromCDS);
  cdsAdmDesc = cdoA.getColValue("cds_adm_desc","");
}

if (mode == null) mode = "add";

if (escSolCdo == null) escSolCdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";
	}else{
	    if (id.trim().equals("0")) throw new Exception("Por favor contacte un administrador [ID no encontrado]");

		sql = "select id, escolta_id escoltaId,pac_id pacId,admision,del_cds delCds,al_cds alCds,cat_admision catAdmision,cama_origen camaOrigen,estado,fecha_ini_sol fechaIniSol,fecha_fin_sol fechaFinSol,usuario_creacion usuarioCreacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion,fecha_modificacion fechaModificacion,usuario_modificacion usuarioModificacion,cama_destino camaDestino, observ, observacion, tipo_sol tipoSol from tbl_esc_sol_escolta where id = "+id+"";

		escSolCdo = SQLMgr.getData(sql);
	    so = (SolEscolta) sbb.getSingleRowBean(ConMgr.getConnection(),sql,SolEscolta.class);
    }

	CommonDataObject cdoCat = SQLMgr.getData("select descripcion from tbl_adm_categoria_admision where codigo = nvl("+admCategory+",0)");

	//System.out.println(".........................GET thebrain> MODE = "+mode+ " NextId = "+so.getEscoltaId());




%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Escolta -  Edici\363n - '+document.title;

function addData(opt){
	switch(opt){
		case 'ESCORT': abrir_ventana('../common/search_escort.jsp?fp=escort'); break; //Escorta
		case 'CDS': abrir_ventana('../common/search_centro_servicio.jsp?fp=escort'); break; //CDS
		case 'CAMA': abrir_ventana('../common/search_cama.jsp?fp=escort'); break; //CAMA
		default: alert();
	}
}
function doAction(){_ctrlToCds();}

function _ctrlToCds(){
   if(document.getElementById("ctrlToCds").checked){
	   	 document.getElementById("observacion").readOnly = false;
	   	 document.getElementById("observacion").className = 'FormDataObjectEnabled';
	   	 document.getElementById("observacion").className = 'FormDataObjectRequired';
   }else{
      	//console.log("unchecked");
      	document.getElementById("observacion").value = "";
   	  	document.getElementById("observacion").readOnly = true;
   	  	document.getElementById("observacion").className = 'FormDataObjectDisabled';
   }
}
function canSubmit(){
 	/*if (document.getElementById("escort").value==""){
		alert('Por favor seleccione une Escolta Anfitri\363n'); return false;
	}else*/
    if(document.getElementById("ctrlToCds").checked){
	   	if(document.getElementById("observacion").value == ""){
	   	   alert('Por favor indique porque el \341rea de destino no es necesario!');return false;
	   	}
    }
   else{
   	  if (document.getElementById("toCDS").value==""){
		 alert('Por favor indique en que \341rea va a estar el paciente!');return false;
      }
   }
   return true;
}
function _doSubmit(){
	if(canSubmit()) document.form0.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - MANTENIMIENTO - ESCOLTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("usuarioCreacion",so.getUsuarioCreacion())%>
				<%=fb.hidden("fechaCreacion",so.getFechaCreacion())%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("admCategory",admCategory)%>
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextPanel">
								<td colspan="4">Solicitud de atenci&oacute;n de anfitri&oacute;n o escolta</td>
							</tr>
							<tr class="TextRow01">
								<!--<td width="5%">Anfitri&oacute;n</td>
								<td width="10%"><%=fb.textBox("escort",so.getEscoltaId(),true,false,true,5,5,null,null,"")%>
									&nbsp;&nbsp;&nbsp;
									<%=fb.button("btnAdd","...",true,false,null,null,"onClick=\"javascript:addData('ESCORT')\"")%>
								</td>-->
								<td></td>
								<td width="55%" colspan="2">&Aacute;rea Origen Paciente&nbsp;&nbsp;&nbsp;
									<%=fb.textBox("fromCDS",fromCDS,false,false,true,5,5,null,null,"")%>
									<%=fb.textBox("cdsAdmDesc",cdsAdmDesc,false,false,true,40,100,null,null,"")%>
								</td>
								<td width="45%">&Aacute;rea Destino&nbsp;&nbsp;&nbsp;
									<%=fb.textBox("toCDS",so.getAlCds(),false,false,true,5,5,null,null,"")%>
									<%=fb.textBox("toCdsDesc",toCdsDesc,false,false,true,25,100,null,null,"")%>
									&nbsp;&nbsp;&nbsp;
									<%=fb.button("btnAdd","...",true,false,null,null,"onClick=\"javascript:addData('CDS')\"")%>
									&nbsp;&nbsp;&nbsp;No aplica
									<%=fb.checkbox("ctrlToCds","",(so.getObservacion()!=null && !so.getObservacion().trim().equals("")),false,null,null,"onClick=\"javascript:_ctrlToCds()\"")%>
								</td>
							</tr>

							<tr class="TextRow01">
								<td colspan="4">
									<table width="100%" cellpadding="2" cellspacing="1" class="TextRow02">
										 <tr class="TextRow01">
										 	<td width="25%">Cama Origen Paciente</td>
										 	<td width="5%"><%=fb.textBox("fromBed",fromBed,false,false,true,5,10,null,null,"")%></td>
										 	<td width="10%" align="right">Cama Destino</td>
										 	<td width="30%"><%=fb.textBox("toBed",so.getCamaDestino(),false,false,true,10,10,null,null,"")%>
										 		&nbsp;&nbsp;&nbsp;
												<%=fb.button("btnAdd","...",true,false,null,null,"onClick=\"javascript:addData('CAMA')\"")%>
										 	</td>
										 	<td width="30%" class="Text12Bold">Categor&iacute;a: <%=cdoCat.getColValue("descripcion")%>
										 	</td>
										 </tr>
										 <tr class="TextRow01" id="obs">
										 	<td>Tipo Solicitud</td>
										 	<td colspan="2">
												<%=fb.select("tipoSol","T=IDA y RETORNO,P=IDA",so.getTipoSol(),false,false,0,null,null,null)%>
										 	</td>
										 	<td align="right">&#191;Porque no aplica&#63;</td>
										 	<td>
										 		<%=fb.textarea("observacion",so.getObservacion(),false,false,true,50,2,1000)%>
										 	</td>
										 </tr>

										  <tr class="TextRow01" id="obs">
										 	<td>Observaci&oacute;n</td>
										 	<td colspan="4">
												<%=fb.textarea("observ",so.getObserv(),false,false,false,50,2,1000)%>
										 	</td>
										 </tr>

									</table>
								<td>
							</tr>


				<tr class="TextRow02">
					<td align="right" colspan="4">
						<!--<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%//=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%//=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%//=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>-->
						<%=fb.button("send","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
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
		String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
		String baction = request.getParameter("baction");

		String observ = (request.getParameter("observacion")==null?"":request.getParameter("observacion"));

		SolEscolta soEsc = new SolEscolta();

		soEsc.setPacId(request.getParameter("pacId"));
		soEsc.setAdmision(request.getParameter("noAdmision"));
		soEsc.setDelCds(request.getParameter("fromCDS"));
		soEsc.setAlCds(request.getParameter("toCDS"));
		soEsc.setCatAdmision(request.getParameter("admCategory"));
		soEsc.setCamaOrigen(request.getParameter("fromBed"));
		soEsc.setEstado("P");
		soEsc.setFechaIniSol(cDate);
		soEsc.setCamaDestino(request.getParameter("toBed"));
		soEsc.setUsuarioModificacion((String) session.getAttribute("_userName"));
		soEsc.setFechaModificacion(cDate);
		soEsc.setObservacion(observ);
		soEsc.setObserv(request.getParameter("observ"));
		soEsc.setTipoSol(request.getParameter("tipoSol"));

	  if (mode.equalsIgnoreCase("add")){

			soEsc.setUsuarioCreacion((String) session.getAttribute("_userName"));
			soEsc.setFechaCreacion(cDate);

			soEsc.setSolId(nextId);

			SolEscMgr.add(soEsc);
			id = soEsc.getSolId();
		}

		else if (mode.equalsIgnoreCase("edit"))
		{
			System.out.println(".........................thebrain> "+mode+ " "+id);
			SolEscMgr.update(soEsc);
		}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SolEscMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SolEscMgr.getErrMsg()%>');
	//window.opener.location = '<%=request.getContextPath()%>/admision/escolta_list.jsp';
	window.close();
<%

} else throw new Exception(SolEscMgr.getErrMsg());
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