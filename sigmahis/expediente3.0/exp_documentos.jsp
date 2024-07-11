<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr" />
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
Admision adm = new Admision();
Admision resp = new Admision();
String key = "";
StringBuffer sbSql = new StringBuffer();
String sql = "";

Hashtable ht = null;
Hashtable iScan = new Hashtable();

String fp = "";
String fg = "";
String tab = "";
String mode = "";
String modeSec = "";
String pacId = "";
String noAdmision = "";
String change = "";
String codigo = "";
String docId = "";
String docDesc = "";
String expStatus = "";
String hidePacHeader = "";
String exp = "";
String areaRevision = "";
String docsFor = "";
int docLastLineNo = 0;

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{

	ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("scanned"),20,true);
	mode = (String) ht.get("mode");
	modeSec = (String) ht.get("modeSec");
	pacId = (String) ht.get("pacId");
	noAdmision = (String) ht.get("noAdmision");
	change = (String) ht.get("change");
	codigo = (String)ht.get("scanId");
	docId = (String) ht.get("docId");
	docDesc = (String)ht.get("docDesc");
	fp = (String)ht.get("fp");
	fg = (String)ht.get("fg");
	tab = (String)ht.get("tab");
	exp = (String)ht.get("exp");
	areaRevision = (String)ht.get("area_revision");
	expStatus = (String)ht.get("expStatus");
	hidePacHeader = (String)ht.get("hidePacHeader");
	docsFor = (String)ht.get("docs_for");
	docLastLineNo = Integer.parseInt(((String)ht.get("docLastLineNo")));

}else{

	fp = request.getParameter("fp");
	fg = request.getParameter("fg");
 	tab = request.getParameter("tab");
 	mode = request.getParameter("mode");
 	modeSec = request.getParameter("modeSec");
 	pacId = request.getParameter("pacId");
    noAdmision = request.getParameter("noAdmision");
	change = request.getParameter("change");
	codigo = request.getParameter("scanId");
 	docId = request.getParameter("docId");
 	docDesc = request.getParameter("docDesc");
 	expStatus = request.getParameter("expStatus");
 	exp = request.getParameter("exp");
 	areaRevision = request.getParameter("area_revision");
 	hidePacHeader = request.getParameter("hidePacHeader");
 	docLastLineNo = (request.getParameter("docLastLineNo")!=null?Integer.parseInt(request.getParameter("docLastLineNo")):0);
 	docsFor = request.getParameter("docs_for");
}

String fecha="",fechaIngreso="";

int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA";
String contCredOptions = "C=CONTADO, R=CREDITO";

if (areaRevision == null) areaRevision = "";
if (exp == null) exp = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (tab == null) tab = "0";
if (hidePacHeader == null) hidePacHeader = "";
boolean viewMode = false;
if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (mode.equalsIgnoreCase("view")||modeSec.equalsIgnoreCase("view") || fg.equalsIgnoreCase("con_sup")) { viewMode = true; estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA"; contCredOptions = "C=CONTADO, R=CREDITO"; }

areaRevision = "'SL'";

if (fg.trim().equalsIgnoreCase("MI")||fg.trim().equalsIgnoreCase("IO")){
    Exception up = new Exception("No pudimos encontrar un tipo de documento válido!");
    if (docId.trim().equals("")) throw up; // :) 
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
    //GETTING THE SCCANNING.....
    sbSql.append("select e.codigo, e.docid docScanId, (SELECT nombre FROM TBL_ADM_DOCUMENTO WHERE codigo=e.docid) AS documentoDesc, decode(e.scanpath,null,' ','");
    sbSql.append(ResourceBundle.getBundle("path").getString("scanned").replaceAll(ResourceBundle.getBundle("path").getString("root"),".."));
    sbSql.append("/'||e.scanpath) as scanPath, nvl(e.scanpath,'') title ,decode(e.scanpath,null,' ','");
    sbSql.append(ResourceBundle.getBundle("path").getString("scanned")+"/'||e.scanpath) as filePath from TBL_ADM_DOC_ESCANEADO e WHERE e.pacid = ");
    sbSql.append(pacId);
    sbSql.append(" and e.secuencia = ");
    sbSql.append(noAdmision);

    if (docsFor.equalsIgnoreCase("hist_pat")||docsFor.equalsIgnoreCase("huellas_materno_infantil")||docsFor.equalsIgnoreCase("informe_oficial")||docsFor.equalsIgnoreCase("protocolo_cesarea")||docsFor.equalsIgnoreCase("sumario_egreso_med_neo")||docsFor.equalsIgnoreCase("protocolo_operatorio")||docsFor.equalsIgnoreCase("hist_cli_pre_ope")||docsFor.equalsIgnoreCase("revision_preoperatoria")||docsFor.equalsIgnoreCase("plan_salida")) {
        sbSql.append(" and e.docid = ");
        sbSql.append(docId);
    }
    
    al2 = SQLMgr.getDataList(sbSql.toString());
    
    if (docsFor.equalsIgnoreCase("hist_pat")||docsFor.equalsIgnoreCase("huellas_materno_infantil")||docsFor.equalsIgnoreCase("informe_oficial")||docsFor.equalsIgnoreCase("protocolo_cesarea")||docsFor.equalsIgnoreCase("sumario_egreso_med_neo")||docsFor.equalsIgnoreCase("protocolo_operatorio")||docsFor.equalsIgnoreCase("hist_cli_pre_ope")||docsFor.equalsIgnoreCase("revision_preoperatoria")||docsFor.equalsIgnoreCase("plan_salida")) {
        if (al2.size() > 0) modeSec = "edit";
    }
    
	if (mode.equalsIgnoreCase("add"))
	{

		iDoc.clear();
		vDoc.clear();

		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		else
		{
			sbSql = new StringBuffer();
			sbSql.append("select to_char(coalesce(f_nac, fecha_nacimiento),'dd/mm/yyyy') as fechaNacimiento, codigo as codigoPaciente, decode(provincia,null,' ',provincia) as provincia, nvl(sigla,' ') as sigla, decode(tomo,null,' ',tomo) as tomo, decode(asiento,null,' ',asiento) as asiento, nvl(d_cedula,' ') as dCedula, nvl(pasaporte,' ') as pasaporte, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as nombrePaciente, vip as key from tbl_adm_paciente where pac_id=");
			sbSql.append(pacId);
			Admision pac = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);
            if (pac == null) pac = new Admision();

			adm.setFechaNacimiento(pac.getFechaNacimiento());
			adm.setCodigoPaciente(pac.getCodigoPaciente());
			adm.setProvincia(pac.getProvincia());
			adm.setSigla(pac.getSigla());
			adm.setTomo(pac.getTomo());
			adm.setAsiento(pac.getAsiento());
			adm.setDCedula(pac.getDCedula());
			adm.setPasaporte(pac.getPasaporte());
			adm.setNombrePaciente(pac.getNombrePaciente());
			adm.setKey(pac.getKey());
		}//else

		noAdmision = "0";
		adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("P");


		}//if add
		else{

		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2, a.dias_hospitalizados as diasHospitalizados, nvl(a.no_cuenta,'') as noCuenta, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, coalesce(a.provincia,(select provincia from tbl_adm_paciente where pac_id=a.pac_id)) as provincia, coalesce(a.sigla,(select sigla from tbl_adm_paciente where pac_id=a.pac_id)) as sigla, coalesce(a.tomo,(select tomo from tbl_adm_paciente where pac_id=a.pac_id)) as tomo, coalesce(a.asiento,(select asiento from tbl_adm_paciente where pac_id=a.pac_id)) as asiento, coalesce(a.d_cedula,(select d_cedula from tbl_adm_paciente where pac_id=a.pac_id)) as dCedula, coalesce(a.pasaporte,(select pasaporte from tbl_adm_paciente where pac_id=a.pac_id)) as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_paciente where pac_id=a.pac_id) as nombrePaciente, (select descripcion from tbl_adm_categoria_admision where codigo=a.categoria) as categoriaDesc, (select descripcion from tbl_adm_tipo_admision_cia where categoria=a.categoria and codigo=a.tipo_admision and compania=a.compania) as tipoAdmisionDesc, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombreMedico, (select nvl(z.descripcion,'NO TIENE') from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=a.medico and x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) as especialidad, coalesce((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico_cabecera),' ') as nombreMedicoCabecera, (select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio) as centroServicioDesc,a.mes_cta_bolsa mesCtaBolsa ,(select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id=a.pac_id) as fechaNacimientoAnt from tbl_adm_admision a where a.pac_id=");
		sbSql.append(pacId);
		sbSql.append(" and a.secuencia=");
		sbSql.append(noAdmision);
		sbSql.append(" and a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);


if (change == null){
	vDoc.clear();
	iDoc.clear();
	sbSql = new StringBuffer();
			sbSql.append("select a.documento, a.revisado_admision as revisadoAdmision, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, (select nombre from tbl_adm_documento where codigo=a.documento) as documentoDesc, a.revisado_sala as revisadoSala, a.revisado_fac as revisadoFac, a.revisado_cob as revisadoCob, a.observacion, a.estatus as estado, a.user_entrega as userEntrega, a.user_recibe as userRecibe, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, to_char(a.fecha_recibe,'dd/mm/yyyy') as fechaRecibe, a.area_entrega as areaEntrega, a.area_recibe as areaRecibe, a.pase, a.pase_k as paseK from tbl_adm_documentos_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
            
            if (docsFor.equalsIgnoreCase("hist_pat")||docsFor.equalsIgnoreCase("huellas_materno_infantil")||docsFor.equalsIgnoreCase("informe_oficial")||docsFor.equalsIgnoreCase("protocolo_cesarea")||docsFor.equalsIgnoreCase("sumario_egreso_med_neo")||docsFor.equalsIgnoreCase("protocolo_operatorio")||docsFor.equalsIgnoreCase("hist_cli_pre_ope")||docsFor.equalsIgnoreCase("revision_preoperatoria")||docsFor.equalsIgnoreCase("plan_salida")) {
                sbSql.append(" and a.documento = ");
                sbSql.append(docId);
            }
            
			sbSql.append(" order by 1");
            
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);
            System.out.println(".......................................... >> ");

			docLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iDoc.put(key, obj);
					vDoc.addElement(obj.getDiagnostico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for
            if(iDoc.size() > 0) modeSec = "edit";
	} //if change's null
	}//else
    
    if (expStatus!=null && expStatus.trim().equalsIgnoreCase("F")) viewMode = true;


al3 = SQLMgr.getDataList("SELECT DISTINCT a.documento, e.docid hasScan FROM TBL_ADM_DOCUMENTOS_ADMISION a, TBL_ADM_DOC_ESCANEADO e WHERE a.pac_id = "+pacId+" AND a.admision = "+noAdmision+" AND  e.docid(+) = a.documento");

for ( int s = 0; s<al3.size(); s++){
  CommonDataObject cdoS = new CommonDataObject();
  cdoS = (CommonDataObject)al3.get(s);
  iScan.put(cdoS.getColValue("documento"),cdoS.getColValue("hasScan"));
}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
document.title = 'Admisión - '+document.title;
var noNewHeight = true;
function doAction(){
 <%if(exp!=null && exp.equals("")){%><%}%>
}

function eliminar(s, fileName)
{ 
	
    top.CBMSG.confirm('Confirma que desea eliminar el escaneado',{
      btnTxt:'Si,No',
      cb: function(r){
        if (r=="Si"){
           var _exe = executeDB('<%=request.getContextPath()%>','call SP_Eliminar_Escan_Doc_Adm('+s+')');
           if (_exe) {
             $.ajax({
                url: '../common/serve_dyn_content.jsp?serveTo=SCANNED_DOC&filePath='+fileName,
                cache: false,
                dataType: "html"
            }).done(function(data){
              if ($.trim(data) == "DELETED") window.location = "<%=request.getContextPath()+request.getServletPath()%>?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&fp=<%=fp%>&fg=<%=fg%>&expStatus=<%=expStatus%>&hidePacHeader=<%=hidePacHeader%>&exp=<%=exp%>&area_revision=<%=areaRevision%>&docId=<%=docId%>&docs_for=<%=docsFor%>&modeSec=<%=modeSec%>";
              else CBMSG.warning(fileName + " no se ha borrado del disco!");
            }).fail(function(jqXHR, textStatus, errorThrown){
               if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
                  alert('Hubo un error 404, por favor contacte un administrador!'); 
               }else{
                  alert('Encontramos este error: '+errorThrown);
               }
            });	
           }
           else top.CBMSG.warning('Hubó un error al tratar de eliminar el documento, \nfavor de contactar el administrador del sistema!!!');
        }
      }
    });
}



var arrVal = new Array();

function getNewSelVal(opt){

 if(hasDBData('<%=request.getContextPath()%>','TBL_ADM_DOCUMENTOS_ADMISION','admision=\'<%=noAdmision%>\' and pac_id=\'<%=pacId%>\'','')){
   arrVal = splitRows(getDBData('<%=request.getContextPath()%>','documento','TBL_ADM_DOCUMENTOS_ADMISION','admision=\'<%=noAdmision%>\' and pac_id=\'<%=pacId%>\'',''));
 }
	var selBox = document.getElementById('docid'+opt);
	var selVal = selBox[selBox.selectedIndex].value;
	var found = 0;
	var len = 0;

	if ( arrVal == null ) {
	  arrVal.push(selVal);
	}else{

	   for ( s = 0; s<arrVal.length; s++ ){
	      if ( arrVal[s] == selVal ){
	      found++ ;
		  selBox.selectedIndex = "";
		  break;
	   }
	}

	if ( selBox ){
	  if ( found == 0 && selBox.selectedIndex != null ){
	 // CBMSG.warning("Found = "+found);
	     arrVal.push(selVal);
	  }
	}
}
	if ( found > 0 ){
	   top.CBMSG.warning("No se puede agregar el mismo documento dos veces para un paciente!");
	   document.getElementById("save").disabled = true;
	}else{document.getElementById("save").disabled = false;}

}


function show(h){
  var hidden = document.getElementById("lb_hidden"+h);
  var btn = document.getElementById("show_btn"+h);
  if(hidden){
      if(hidden.style.display=='none'){
	      hidden.style.display = '';
		  btn.style.display = 'none';
	  }else{hidden.style.display='none';
	      btn.style.display = '';
	  }
  }
}

function ctrlNullDoc(){
    var size = <%=iDoc.size()%>;

	for ( i = 1; i<=size; i++ ){

		 if (document.getElementById('docid'+i)){
			 var selBox = document.getElementById('docid'+i);
			 var selVal = selBox[selBox.selectedIndex].value;
			 if (selVal == ''){
				 top.CBMSG.warning("No se permite grabar un documento en blanco");
				 document.getElementById("save").disabled = true;
				 break;
			 }
		 }
    }
}
function ctrlDoc(){
    var size = <%=iDoc.size()%>;

	for ( i = 1; i<=size; i++ )
	{
		 var escaneado = document.getElementById('escaneado'+i).value;
		 if (escaneado !='')
		 {
			 if(escaneado.length - escaneado.lastIndexOf("\\")>58)
			 {
				top.CBMSG.warning('El documento '+escaneado.substring(escaneado.lastIndexOf("\\")+1)+' Tiene un nombre demasiado largo!(>58)');
				return false;
				break;
			 }

		 }
    }
	return true;
}
</script>

</head>
<body class="body-form" topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<div class="headerform">
</div>

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("expStatus",expStatus)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("hidePacHeader",hidePacHeader)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("area_revision", areaRevision)%>
<%=fb.hidden("docs_for", docsFor)%>
<%=fb.hidden("docId", docId)%>
<%fb.appendJsValidation("if(!ctrlDoc())error++;");%>
<table cellspacing="0" class="table table-small-font table-bordered">
<tr class="bg-headtabla2" align="center">
    <td width="7%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
    <td width="84%"><cellbytelabel id="9">Documento</cellbytelabel></td>
    <td width="7%"><cellbytelabel id="10">Verificado</cellbytelabel></td>
    <td width="2%">
        <button type="button" name="addDocumento" id="addDocumento" value="+" class="btn btn-inverse btn-sm" onclick="__submitForm(this.form, this.value)"<%=iDoc.size()>0?" disabled":""%> title="Agregar Documentos"><i class="fa fa-plus fa-lg"></i> </button>
    </td>
</tr>
<%
al = CmnMgr.reverseRecords(iDoc);
String groupByDoc = "";
CommonDataObject cdo = new CommonDataObject();
String  disp = "";
String hidden = "";
boolean hasPic = false;

for (int i=1; i<=iDoc.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iDoc.get(key);
%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("documento"+i,obj.getDocumento())%>
						<%=fb.hidden("documentoDesc"+i,obj.getDocumentoDesc())%>
						<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
						<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
						<%=fb.hidden("revisadoSala"+i,obj.getRevisadoSala())%>
						<%=fb.hidden("revisadoFac"+i,obj.getRevisadoFac())%>
						<%=fb.hidden("revisadoCob"+i,obj.getRevisadoCob())%>
						<%=fb.hidden("observacion"+i,obj.getObservacion())%>
						<%=fb.hidden("estado"+i,obj.getEstado())%>
						<%=fb.hidden("userEntrega"+i,obj.getUserEntrega())%>
						<%=fb.hidden("userRecibe"+i,obj.getUserRecibe())%>
						<%=fb.hidden("fechaEntrega"+i,obj.getFechaEntrega())%>
						<%=fb.hidden("fechaRecibe"+i,obj.getFechaRecibe())%>
						<%=fb.hidden("areaEntrega"+i,obj.getAreaEntrega())%>
						<%=fb.hidden("areaRecibe"+i,obj.getAreaRecibe())%>
						<%=fb.hidden("pase"+i,obj.getPase())%>
						<%=fb.hidden("paseK"+i,obj.getPaseK())%>
                        
                        <%
                         if (obj.getDocumento() != null && !obj.getDocumento().trim().equals("")) {}
                         else obj.setDocumento(docId);
                        %>
						<tr class="TextRow01">
							<td><%=obj.getDocumento()%></td>
							<td class="controls form-inline">
							<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, area_revision as area from tbl_adm_documento where area_revision IN ("+areaRevision+") order by nombre","docid"+i,obj.getDocumento(),true,false,(viewMode),0,"form-control input-sm hidden",null,"onchange=\"getNewSelVal("+i+")\"","","")%>

						<%
							//
							if (iScan.get(obj.getDocumento())!= null && iScan.get(obj.getDocumento()).equals(obj.getDocumento())){
							   	disp = "style=\"display:none;\"";
								hasPic = true;
								hidden = obj.getDocumento();
							}else{
							   disp = "style=\"display:'';\"";
							   hasPic = false;
							   hidden = "";
							}
						%>
						<%=fb.hidden("has_pic"+i,""+hasPic)%>
						<%=(hasPic?fb.button("show_btn"+hidden,"+",true,viewMode,null,"","onClick=\"show('"+hidden+"')\"","Agregar mas imágenes"):"")%>
					    <span id="lb_hidden<%=hidden%>" <%=disp%>>&nbsp;&nbsp;&nbsp;<cellbytelabel id="11">Escaneado</cellbytelabel><%=fb.fileBox("escaneado"+i,"",false,false,15,"","","")%></span>
			<%
				if ( al2.size() > 0 ){
					for ( int s = 0; s<al2.size(); s++){
					  cdo = (CommonDataObject)al2.get(s);

					    /*String fileTitle = "";
  						String[] fileTitleTmp;
   						int dot;

						fileTitle = cdo.getColValue("scanpath");
      					try {
	  						 fileTitleTmp = fileTitle.split("_");
	   						 dot = fileTitleTmp[1].lastIndexOf(".");

	   						 if ( dot > 0 ){
		 					     fileTitleTmp[1] = fileTitleTmp[1].substring(0,dot);
	   					     }
      					}catch(Exception e){
	  				      fileTitleTmp = fileTitle.split("_");
      		            }*/

					  if (cdo.getColValue("docScanId").equals(obj.getDocumento())){
					  %>
					     <img src="../images/search.gif" id="scan<%=i%>" width="20" height="20" onClick="javascript:abrir_ventana('../common/abrir_ventana.jsp?fileName=<%=cdo.getColValue("scanPath")%>')" style="cursor:pointer; display:inline; vertical-align:middle;" title="<%=cdo.getColValue("title")%>"/>&nbsp;&nbsp;<%=cdo.getColValue("title")%>&nbsp;&nbsp;<a href="javascript:eliminar(<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("filePath")%>')"  class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')" title="Eliminar: <%=cdo.getColValue("title")%>">X</a>&nbsp;&nbsp;


			<%
			} //group by docid
			} //for s
			} //if al2.size() > 0
			%>
            </td>
            <td align="center"><%=fb.checkbox("revisadoAdmision"+i,"S",(obj.getRevisadoAdmision() != null && obj.getRevisadoAdmision().equalsIgnoreCase("S")),viewMode)%></td>
            <td align="center">
                <button type="button" name="rem<%=i%>" id="rem<%=i%>" value="x" class="btn btn-inverse btn-sm" onclick="javascript:removeItem(this.form.name,<%=i%>);__submitForm(this.form, this.value)"<%=hasPic?" disabled":"Eliminar Documento"%> title="<%=hasPic?"Por favor elimina primero el escaneado!":""%>"><i class="fa fa-trash-o fa-lg"></i> </button>
            </td>
            </tr>

<%
}//for


%>
    </table>
    
    <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td>
                    <%=fb.hidden("saveOption","O")%>
                    <button type="button" name="save" id="save" value="Guardar" class="btn btn-inverse btn-sm" onclick="javascript:__submitForm(this.form,this.value);"<%=viewMode?" disabled":""%>><i class="fa fa-floppy-o fa-lg"></i> Guardar</button>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
               </td>
            </tr>
        </table>   
    </div>

<%=fb.formEnd(true)%>

</div>
</div>

</body>
</html>
<%
} //get

else{
	String saveOption = (String)ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = (String)ht.get("baction");
	String errCode = "";
	String errMsg = "";

	adm = new Admision();
	adm.setPacId((String)ht.get("pacId"));
	adm.setNoAdmision((String)ht.get("noAdmision"));
	adm.setFechaNacimiento((String)ht.get("fechaNacimiento"));
	adm.setCodigoPaciente((String)ht.get("codigoPaciente"));
	adm.setCompania((String) session.getAttribute("_companyId"));
	adm.setUsuarioModifica((String) session.getAttribute("_userName"));

		int size = 0;
		if ( ((String)ht.get("docSize")) != null) size = Integer.parseInt(((String)ht.get("docSize")));
		String itemRemoved = "";

		adm.getDocumentos().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setDocumento((String)ht.get("docid"+i));
			obj.setDocumentoDesc((String)ht.get("documentoDesc"+i));
			if ( (String)ht.get("revisadoAdmision"+i) != null && ((String)ht.get("revisadoAdmision"+i)).equalsIgnoreCase("S") )
				obj.setRevisadoAdmision("S");
			else
				obj.setRevisadoAdmision("N");
			obj.setUsuarioCreacion((String)ht.get("usuarioCreacion"+i));
			obj.setFechaCreacion((String)ht.get("fechaCreacion"+i));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));

			obj.setRevisadoSala((String)ht.get("revisadoSala"+i));
			obj.setRevisadoFac((String)ht.get("revisadoFac"+i));
			obj.setRevisadoCob((String)ht.get("revisadoCob"+i));
			obj.setObservacion((String)ht.get("observacion"+i));
			obj.setEstado((String)ht.get("estado"+i));

			obj.setUserEntrega((String)ht.get("userEntrega"+i));
			obj.setUserRecibe((String)ht.get("userRecibe"+i));
			obj.setFechaEntrega((String)ht.get("fechaEntrega"+i));
			obj.setFechaRecibe((String)ht.get("fechaRecibe"+i));
			obj.setAreaEntrega((String)ht.get("areaEntrega"+i));
			obj.setAreaRecibe((String)ht.get("areaRecibe"+i));
			obj.setPase((String)ht.get("pase"+i));
			obj.setPaseK((String)ht.get("paseK"+i));

			obj.setKey((String)ht.get("key"+i));

			if ((String)ht.get("remove"+i) != null && !((String)ht.get("remove"+i)).equals(""))
				itemRemoved = obj.getKey();
			else
			{
				try
				{
					iDoc.put(obj.getKey(),obj);
					adm.addDocumento(obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			Admision obj = (Admision) iDoc.get(itemRemoved);
			vDoc.remove(obj.getDocumento());
			iDoc.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&docLastLineNo="+docLastLineNo+"&fp="+fp+"&fg="+fg+"&expStatus="+expStatus+"&hidePacHeader="+hidePacHeader+"&exp="+exp+"&area_revision="+areaRevision+"&docId="+docId+"&docs_for="+docsFor);
			return;
		}

		if (baction != null && baction.equals("+"))
		{

		docLastLineNo++;

		Admision obj = new Admision();

				if (docLastLineNo < 10) key = "00" + docLastLineNo;
				else if (docLastLineNo < 100) key = "0" + docLastLineNo;
				else key = "" + docLastLineNo;
				obj.setKey(key);

				try
				{
					iDoc.put(key, obj);
					vDoc.addElement(obj.getDiagnostico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&docLastLineNo="+docLastLineNo+"&fp="+fp+"&fg="+fg+"&expStatus="+expStatus+"&hidePacHeader="+hidePacHeader+"&exp="+exp+"&area_revision="+areaRevision+"&docId="+docId+"&docs_for="+docsFor);
			return;
		}

 if ( baction.equals("Guardar") ){

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equalsIgnoreCase("add")) AdmMgr.saveDocumento(adm);
		else AdmMgr.updateDocumento(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
        
if ( errCode.equals("1") ){
	ArrayList alScan = new ArrayList();


   for ( int s = 1; s<=size; s++ ){

      CommonDataObject cdoScan = new CommonDataObject();

	  // ((String)ht.get("escaneado")) != null ||

	  if (!((String)ht.get("escaneado"+s)).equals("") ){

	  String docPath = "";

      cdoScan.setTableName("tbl_adm_doc_escaneado");
      cdoScan.setAutoIncCol("codigo");
 	  cdoScan.addColValue("pacid",(String)ht.get("pacId"));
	  cdoScan.addColValue("secuencia",(String)ht.get("noAdmision"));

	  docPath = (String)ht.get("escaneado"+s);
	  docPath = CmnMgr.cleanFile(docPath);

	  System.out.println(":thebrain :::::::::::::::::::::::::::"+docPath);
      cdoScan.addColValue("docid",(String)ht.get("docid"+s));
	  cdoScan.addColValue("scanpath",docPath);

	  alScan.add(cdoScan);
	  }//if not null

   }//for s


   if ( alScan.size() == 0 ){
       CommonDataObject cdoScan = new CommonDataObject();
	   cdoScan.setTableName("tbl_adm_doc_escaneado");
	   //cdoScan.setWhereClause("pacid="+pacId+" and secuencia="+noAdmision);
	   cdoScan.setWhereClause("codigo=-1");
	   //cdoScan.setAutoIncCol("codigo");
	   alScan.add(cdoScan);
   }

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "docsFor="+docsFor+", fp="+fp+", fg="+fg);
		SQLMgr.insertList(alScan,true,false);
		ConMgr.clearAppCtx(null);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();

  }//IF ERROR CODE IS 1 (SUCCESFUL)

 }//if guardar
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = "<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&expStatus=<%=expStatus%>&hidePacHeader=<%=hidePacHeader%>&exp=<%=exp%>&area_revision=<%=areaRevision%>&docId=<%=docId%>&docs_for=<%=docsFor%>&modeSec=<%=modeSec%>";
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>