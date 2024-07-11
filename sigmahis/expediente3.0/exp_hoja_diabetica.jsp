<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.HojaDiabetica"%>
<%@ page import="issi.expediente.DetalleDiabetica"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iHojaDiab" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HojaMgr" scope="session" class="issi.expediente.HojaDiabeticaMgr"/>
<jsp:useBean id="iDiabetica" scope="session" class="java.util.Hashtable"/>
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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
HojaMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList alViaAd = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

HojaDiabetica objDiab = new  HojaDiabetica();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fechaEval = request.getParameter("fecha_eval")==null?"":request.getParameter("fecha_eval");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String fecha_eval = request.getParameter("fecha_eval");
String filter = "", op="", appendFilter = "";
int diabLastLineNo =0;
int ihojaLastLineNo =0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getParameter("diabLastLineNo") != null) diabLastLineNo = Integer.parseInt(request.getParameter("diabLastLineNo"));

String reqField = "GLU";
String diabeticTime = "";
cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'EXP_DIABETIC_CTRL'),'GLU') as reqField, nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'EXP_DIABETIC_TIME'),'-') as diabeticTime from dual");
if (cdo != null) {
	reqField = cdo.getColValue("reqField");
	diabeticTime = cdo.getColValue("diabeticTime");
}
if (diabeticTime.equals("-")) diabeticTime = "6=6 A.M,11=11 A.M,4=4 P.M,9=9 P.M";

CommonDataObject cdoOM = SQLMgr.getData("select distinct insulina, via siNo from tbl_sal_esquema_insulina where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha = (select max(fecha) from tbl_sal_esquema_insulina where pac_id = "+pacId+" and admision = "+noAdmision+")");
  if (cdoOM == null) cdoOM = new CommonDataObject();
  
boolean restrictDate = false;

if (request.getMethod().equalsIgnoreCase("GET"))
{

  if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	iDiabetica.clear();
	sql = "select to_char(fecha,'dd/mm/yyyy') as fecha from TBL_SAL_HOJA_DIABETICA a where pac_id="+pacId+" and secuencia="+noAdmision+" order by a.fecha desc";
	al2 = SQLMgr.getDataList(sql);
	ihojaLastLineNo = al2.size();
	alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where status='A' and tipo_liquido='D' order by descripcion",CommonDataObject.class);

	for (int i=1; i<=al2.size(); i++)
	{
		cdo = (CommonDataObject) al2.get(i-1);
		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;
		cdo.addColValue("key",key);

		if(cdo.getColValue("fecha").equals(cDateTime.substring(0,10)))
		{
			cdo.addColValue("OBSERVACION","Evaluacion actual ");
			op = "0";
		}
		else
		{
			cdo.addColValue("OBSERVACION","Evaluacion "+ (1+ihojaLastLineNo - i));
			appendFilter = "1";
		}
		try
		{
			iDiabetica.put(key, cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}//for
	if (al2.size() == 0)
	{
		cdo = new CommonDataObject();
		cdo.addColValue("FECHA",cDateTime.substring(0,10));
		cdo.addColValue("OBSERVACION","Evaluacion Actual");
		ihojaLastLineNo++;
		if (ihojaLastLineNo < 10) key = "00" + ihojaLastLineNo;
		else if (ihojaLastLineNo < 100) key = "0" + ihojaLastLineNo;
		else key = "" + ihojaLastLineNo;
		cdo.addColValue("key",key);
		op = "0";
		try
		{
			iDiabetica.put(key, cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
	if (fecha_eval != null)
	{
		filter = fecha_eval;
		if (fecha_eval.equals(cDateTime.substring(0,10)))
		{
			if (!viewMode)
			{
				modeSec = "edit";
				viewMode = false;
			}
		}
	}
	else filter = cDateTime.substring(0,10);

	sql = "select to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo_personal as tipoPersonal, a.personal_g as personalG, a.emp_provincia as empProvincia, a.emp_sigla as empSigla, a.emp_tomo as empTomo, a.emp_asiento as empAsiento, a.emp_compania as empCompania, a.personal as personal, a.usuario_creacion as usuarioCeacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion, a.emp_id as empId FROM TBL_SAL_HOJA_DIABETICA a where a.pac_id="+pacId+" and a.secuencia="+noAdmision +" and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy')";
	objDiab = (HojaDiabetica) sbb.getSingleRowBean(ConMgr.getConnection(), sql, HojaDiabetica.class);
	//System.out.println("sql =  "+sql);
	if(objDiab == null)
	{
		objDiab = new HojaDiabetica();
		objDiab.setFecha(filter);
		objDiab.setUsuarioCreacion(UserDet.getUserName());
		objDiab.setFechaCreacion(cDateTime);
		objDiab.setUsuarioModificacion(UserDet.getUserName());
		objDiab.setFechaModificacion(cDateTime);
		objDiab.setEmpCompania((String) session.getAttribute("_companyId"));
		if (!viewMode) modeSec = "add";
	}
	else if (!viewMode) modeSec = "edit";

	if (change == null)
	{
		iHojaDiab.clear();
		sql = "select codigo, to_char(fecha_hoja,'dd/mm/yyyy') as fechaHoja, glucosa, cantidad, to_char(hora,'hh12:mi:ss am') as hora, si_no as siNo, observacion, acetona, insulina,tiempo,glicema glicemia from tbl_sal_detalle_diabetica where pac_id="+pacId+" and secuencia="+noAdmision+" and to_date(to_char(fecha_hoja,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy')";

		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDiabetica.class);
		//System.out.println("sqlDet =  "+sql);
		diabLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			try
			{
				iHojaDiab.put(key, al.get(i-1));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{
			//if (!viewMode) mode = "add";
			DetalleDiabetica newDet = new DetalleDiabetica();
			newDet.setHora(cDateTime.substring(11));
			newDet.setFechaHoja(objDiab.getFecha());
			newDet.setCodigo("0");
			newDet.setCantidad("1");
			//newDet.setInsulina(cdoOM.getColValue("insulina"));
			newDet.setSiNo(cdoOM.getColValue("siNo"));
			
			diabLastLineNo++;
			if (diabLastLineNo < 10) key = "00" + diabLastLineNo;
			else if (diabLastLineNo < 100) key = "0" + diabLastLineNo;
			else key = "" + diabLastLineNo;
			try
			{
				iHojaDiab.put(key,newDet);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		} else {
			restrictDate = true;
		}
	}
	//else if (!viewMode) mode = "edit";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
document.title = 'HOJA DIABETICA - '+document.title;
var noNewHeight = true;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verHoja(k){var fecha_e=eval('document.form0.fecha_evaluacion'+k).value;window.location='../expediente3.0/exp_hoja_diabetica.jsp?&modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e+'&desc=<%=desc%>';}
function chartHoja(){abrir_ventana1('../expediente/chart_hoja_diabetica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&stamp=<%=new java.util.Date()%>');}
function imprimir(all){
    if(!all) abrir_ventana1('../expediente3.0/print_hoja_diabetica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fechaEval=<%=filter%>');
	else abrir_ventana1('../expediente3.0/print_hoja_diabetica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fechaEval=');
}
function addHoja(){
	window.document.location = "../expediente3.0/exp_hoja_diabetica.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&modeSec=add&mode=add&fecha_eval=";
}
var xHeight=0;
function doAction(){checkViewMode();}

jQuery(document).ready(function(){

  function rangoFechaCtrl(action){
    $("#rangoFecha input").each(function(i,el){
       var $el = $(el);
	   if (action == "E") {
	     $el.prop("readonly",false);
	     $el.prop("disabled",false);
	     $("#reset"+$el.attr('id')).prop("disabled",false);
	   }
	   else if(action == "D") {
	     $el.prop("readonly",true).val("");
	     $el.prop("disabled",true).val(""); 
         $("#reset"+$el.attr('id')).prop("disabled",true);
	   }
	});
  }
  
  $("#horario").change(function(e){
     var horario = $(this).val();
	 if (horario=="todos"){	 
		rangoFechaCtrl('E');
		$("#rangoFecha").show(0);
	 }else {
		 rangoFechaCtrl('D');
		 $("#rangoFecha").hide(0);
	 }
  });

  
  $("#view_chart, #print_chart").click(function(v){
    var horario = $("#horario").val();
	var from = $("#from").val()||'';
	var to = $("#to").val()||'';
	var fechaEval = "<%=fechaEval%>";
	if (horario=="todos" && (!from || !to) && !fechaEval) parent.CBMSG.alert("Por favor escoge un rango de fecha!");
	else {
	   if ($(this).attr("id") == "view_chart") abrir_ventana1('../expediente/chart_hoja_diabetica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&stamp=<%=new java.util.Date()%>&horario='+horario+'&from='+from+'&to='+to+'&fechaEval='+fechaEval);
	   else abrir_ventana1('../expediente/print_chart_hoja_diabetica.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&seccion=<%=mode%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&stamp=<%=new java.util.Date()%>&horario='+horario+'&from='+from+'&to='+to+'&fechaEval='+fechaEval);
	}
  });
  
  
  $(".btn_insulinas").click(function() {
    var self = $(this);
    var i = self.data('i');
	var fecha=$("#fecha").val();
	parent.showPopWin('../expediente3.0/sel_glucometros.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&index='+i+'&fecha='+fecha,winWidth*.50,winHeight*.45,null,null,'');
    
  });
  
  
});
function getInsulinas(i) {
  
  var glicemia = $("#glicemia"+i).val() || '0';
  $("#insulina"+i).val("");
  var __continue = false;
  glicemia = parseInt(glicemia);
  if ($.trim(glicemia)) {
    var insulinas = splitRows(getDBData('<%=request.getContextPath()%>','escala, valor','tbl_sal_esquema_insulina',"pac_id = <%=pacId%> and admision = <%=noAdmision%>",' order by codigo')) || [];
    for (var d = 0; d < insulinas.length; d++) {
      var escala = insulinas[d].split("|")[0];
      var valor = insulinas[d].split("|")[1];
      // menor
      if ( escala.indexOf("<=") > -1 ) {
		 escala = $.trim(escala.split("<=")[1]) || '0';
        var _escala = parseInt(escala);
        if (glicemia <= _escala) {
          $("#insulina"+i).val(valor.replace(/\D/g,''));
          break;
        } else __continue = true;
      } 
      
      if (__continue){
          if ( escala.indexOf(">") > -1  ) {
            escala = $.trim(escala.split(">")[1]) || '0';
            var _escala = parseInt(escala);
            if (glicemia > _escala) {
              $("#insulina"+i).val(valor.replace(/\D/g,''));
              break;
            } else __continue = true;
          }
      }
      
      if (__continue){
          if (escala.indexOf("-") > -1 ) {
			 var rango = escala.split("-");
             var from = $.trim(rango[0]) || '0';
             var to = $.trim(rango[1]) || '0';
             from = parseInt(from);
             to = parseInt(to);
			 console.log(from+'------'+to+'- '+glicemia);
             if ( glicemia >= from && glicemia <= to ) {
                $("#insulina"+i).val(valor.replace(/\D/g,''));
                break;
             } else __continue = true;
          }
      }
    }
  }
  
}

function verHistorial() {
  $("#hist_container").toggle();
}

$(function() {
	$("#fecha").change(function() {
		console.log('----', this.defaultValue);
	})
})

function checkResultsTime () {
	var oldValue = document.querySelector("#fecha").defaultValue;
	var cValue = $("#fecha").val();
	var check = $("#from_results").val() != '';
	if (check && oldValue != cValue) {
		if(confirm("Al cambiar la fecha se borraran las horas y los valores en glicemia")) {
			$(".horas, .glicemia").val("");
		} else $("#fecha").val(oldValue);
	}
}

function canProceed() {
	if (!$("#fecha").val()) {
		alert("Por favor indique la fecha");
		return false;
	}
	return true;
}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">

<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<div class="headerform">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canProceed()) error++;");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("diabLastLineNo",""+diabLastLineNo)%>
<%=fb.hidden("size",""+iHojaDiab.size())%>
<%=fb.hidden("tipoPersonal",objDiab.getTipoPersonal())%>
<%=fb.hidden("personalG",objDiab.getPersonalG())%>
<%=fb.hidden("empProvincia",objDiab.getEmpProvincia())%>
<%=fb.hidden("empSigla",objDiab.getEmpSigla())%>
<%=fb.hidden("empTomo",objDiab.getEmpTomo())%>
<%=fb.hidden("empAsiento",objDiab.getEmpAsiento())%>
<%=fb.hidden("empCompania",objDiab.getEmpCompania())%>
<%=fb.hidden("personal",objDiab.getPersonal())%>
<%=fb.hidden("usuarioCreacion",objDiab.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",objDiab.getFechaCreacion())%>
<%=fb.hidden("usuarioModificacion",objDiab.getUsuarioModificacion())%>
<%=fb.hidden("fechaModificacion",objDiab.getFechaModificacion())%>
<%=fb.hidden("empId",objDiab.getEmpId())%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fecha_eval",filter)%>
<%=fb.hidden("from_results","")%>

    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
        <td class="controls form-inline">
			<%if (request.getParameter("fecha_eval") == null || "".equals(request.getParameter("fecha_eval")) ){%>
			<%}%>
			<%=fb.button("_imprimir","Imprimir Todos",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir(1)\"")%>
			<%=fb.button("_imprimir","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir()\"")%>
            <%if (!viewMode || !mode.equals("add") ){%>
                <button type="button" name="agregar" id="agregar" class="btn btn-inverse btn-sm" onclick="javascript:addHoja()"><i class="fa fa-plus fa-lg"></i> Agregar</button>
             <%}%>
       
         <span style="<%=!fechaEval.equals("")?"display:none":""%>"><cellbytelabel id="10">Opciones</cellbytelabel>: <%=fb.select("horario","todos=TODOS|_24h=ULTIMAS 24/H|turnoActual=TURNO ACTUAL","turnoActual",false,false,0,"form-control input-sm",null,"",null,null,null,"|",null)%></span>
         <span style="display:none" id="rangoFecha"> 
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2"/>
                <jsp:param name="nameOfTBox1" value="from"/>
                <jsp:param name="valueOfTBox1" value=""/>
                <jsp:param name="nameOfTBox2" value="to"/>
                <jsp:param name="valueOfTBox2" value=""/>
                <jsp:param name="clearOption" value="true"/>
                <jsp:param name="readonly" value="y"/>
            </jsp:include>
        </span>
         
         <button type="button" name="view_chart" id="view_chart" class="btn btn-inverse btn-sm" onclick="javascript:void(0)"><i class="fa fa-eye fa-lg"></i> Ver Gr&aacute;fica</button>
         
         <button type="button" name="print_chart" id="print_chart" class="btn btn-inverse btn-sm" onclick="javascript:void(0)"><i class="fa fa-print fa-lg"></i> Ver Gr&aacute;fica</button>
		 
		 <%if(al2.size() > 0){%>
			<button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
				<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
			</button>
		<%}%>
         
      </td>
    </tr>
    </table>

    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <thead>
            <!--<tr>
                <td colspan="2">&nbsp;<cellbytelabel id="4">Listado de Evaluaciones - Hoja Diabetica</cellbytelabel></td>
            </tr>-->
            <tr class="bg-headtabla2">
                <th width="30%"><cellbytelabel id="5">Fecha</cellbytelabel></th>
                <th width="70%"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel></th>
            </tr>
        </thead>
        <tbody>
         <%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
            <%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
            <tr class="pointer" onClick="javascript:verHoja(0)" >
                <td><%=cDateTime.substring(0,10)%></td>
                <td><cellbytelabel id="7">Evaluaci&oacute;n actual</cellbytelabel></td>
            </tr>
        <%}
        al2 = CmnMgr.reverseRecords(iDiabetica);
        for (int i=1; i<=iDiabetica.size(); i++){
            key = al2.get(i-1).toString();
            cdo = (CommonDataObject) iDiabetica.get(key);
        %>
            <%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
				<tr class="pointer" onClick="javascript:verHoja(<%=i%>)">
					<td><%=cdo.getColValue("fecha")%></td>
					<td><%=cdo.getColValue("observacion")%></td>
				</tr>
        <%}%>
        </tbody>
        </table>
    </div>
</div>       
   <table cellspacing="0" class="table table-small-font table-bordered">
        <tr>
          <td colspan="9"></td>
        </tr>   
         <tr>
			<td colspan="9" class="controls form-inline">
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="fromLbl" value="Fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=objDiab.getFecha()%>"/>
                <jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="readonly" value="<%=(viewMode||restrictDate)?"y":"n"%>"/>
				<jsp:param name="jsEvent" value="<%="checkResultsTime()"%>" />
				</jsp:include>
			</td>
		</tr>
		<tr class="bg-headtabla">
			<td width="12%"><cellbytelabel id="8">Hora</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="12">Glicemia Capilar</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="11">Insulina</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="14">V&iacute;a</cellbytelabel></td>
			<td width="45%"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel></td>
			<td width="3%" align="center">
            <%=fb.submit("agregar","+",false,viewMode,"btn btn-primary btn-xs",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value); __submitForm(this.form, this.value)\"","Agregar Item")%></td>
		</tr>
<%
al.clear();
al = CmnMgr.reverseRecords(iHojaDiab);

for (int i = 1; i <= iHojaDiab.size(); i++){
	key = al.get(i - 1).toString();
	DetalleDiabetica newDet = (DetalleDiabetica) iHojaDiab.get(key);%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("codigo"+i,newDet.getCodigo())%>
		<%=fb.hidden("fechaHoja"+i,newDet.getFechaHoja())%>
		<%=fb.hidden("cantidad"+i,newDet.getCantidad())%>
			<tr>
			<td class="controls form-inline">
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi:ss am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora"+i%>"/>
				<jsp:param name="valueOfTBox1" value="<%=newDet.getHora()%>"/>
				<jsp:param name="readonly" value="<%=(viewMode||restrictDate)?"y":"n"%>"/>
				<jsp:param name="fieldClass" value="horas"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="hintText" value="Ej: 01:30:00 AM"/>
				</jsp:include>
			</td>
			<td class="controls form-inline"><%=fb.decBox("glicemia"+i,newDet.getGlicemia(),(reqField.equalsIgnoreCase("GLY")),false,viewMode,8,3.3,"form-control input-sm glicemia","","onblur='getInsulinas("+i+")'")%>
				<button type="button" class="btn btn-inverse btn-sm btn_insulinas ctrl<%=i%>" id="btn_insulinas<%=i%>"<%=viewMode? " disabled" : ""%> data-i="<%=i%>">...</button>
			</td>
			<td>
				<%=fb.textBox("insulina"+i,newDet.getInsulina(),false,false,viewMode,5,30,"form-control input-sm","","")%>
			</td>
			<td><%=fb.select("siNo"+i,alViaAd,newDet.getSiNo(),false,viewMode,0,"form-control input-sm",null,null,"","S")%></td>
			<td align="left"><%=fb.textarea("observacion"+i,newDet.getObservacion(),false,false,viewMode,25,1,0,"form-control input-sm",null,"")%></td>
			<td align="center">
                       
            <%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-primary btn-xs",null,"onclick=\"removeItem(this.form.name,"+i+");__submitForm(this.form, this.value)\"")%>
            
            </td>
		</tr>
<%
}
%>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
            <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
        </tr>
    </table>   
</div>
        
<%=fb.formEnd(true)%>

 </div>
 </div>
 </div>
</body>
</html>
<%
}//fin GET
else
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	int sizehoja = 0;
	if (request.getParameter("size") != null) sizehoja = Integer.parseInt(request.getParameter("size"));
	String itemRemoved = "";
	al.clear();
	HojaDiabetica hoja = new HojaDiabetica();

	hoja.setSecuencia(request.getParameter("noAdmision"));
	hoja.setCodPaciente(request.getParameter("codPac"));
	hoja.setFecNacimiento(request.getParameter("dob"));
	hoja.setFecha(request.getParameter("fecha"));
	hoja.setTipoPersonal(request.getParameter("tipoPersonal"));
	hoja.setPersonalG(request.getParameter("personalG"));
	hoja.setEmpProvincia(request.getParameter("empProvincia"));
	hoja.setEmpSigla(request.getParameter("empSigla"));
	hoja.setEmpTomo(request.getParameter("empTomo"));
	hoja.setEmpAsiento(request.getParameter("empAsiento"));
	hoja.setEmpCompania(request.getParameter("empCompania"));
	hoja.setPersonal(request.getParameter("personal"));
	hoja.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	hoja.setFechaCreacion(request.getParameter("fechaCreacion"));
	hoja.setUsuarioModificacion(request.getParameter("usuarioModificacion"));
	hoja.setFechaModificacion(request.getParameter("fechaModificacion"));
	hoja.setPacId(request.getParameter("pacId"));
	hoja.setEmpId(request.getParameter("empId"));

	for (int i=1; i<= sizehoja; i++)
	{
		DetalleDiabetica detHoja = new DetalleDiabetica();

		detHoja.setSecuencia(request.getParameter("noAdmision"));
		detHoja.setFecNacimiento(request.getParameter("dob"));
		detHoja.setCodPaciente(request.getParameter("codPac"));
		detHoja.setPacId(request.getParameter("pacId"));

		detHoja.setFechaHoja(request.getParameter("fecha")); //fechaHora+i // Eso hace que Viola SHD_SDA_FK
		detHoja.setCodigo(""+i);
		detHoja.setHora(request.getParameter("hora"+i));

		detHoja.setCantidad(request.getParameter("cantidad"+i));
		detHoja.setInsulina(request.getParameter("insulina"+i));
		detHoja.setGlicemia(request.getParameter("glicemia"+i)); // Estaban usando el método setGlucosa() en vez de set Glicemia()

		if (baction.equalsIgnoreCase("Guardar") && (detHoja.getGlucosa() == null || detHoja.getGlucosa().trim().equals("")) && (detHoja.getGlicemia() == null || detHoja.getGlicemia().trim().equals(""))) throw new Exception("Por favor completar el valor para la glucosa o para la glicemia!");


		detHoja.setObservacion(request.getParameter("observacion"+i));
		detHoja.setSiNo(request.getParameter("siNo"+i));
		key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		itemRemoved = key;
		else
		{
			try
			{
				al.add(detHoja);
				iHojaDiab.put(key,detHoja);
				hoja.addDetalleDiabetica(detHoja);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
	if(!itemRemoved.equals(""))
	{
		iHojaDiab.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&diabLastLineNo="+diabLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&fecha_eval="+request.getParameter("fecha"));
		return;
	}

	if(baction.equals("+"))//Agregar
	{
		DetalleDiabetica newDetalle= new DetalleDiabetica();

		newDetalle.setFechaHoja(request.getParameter("fecha"));
		newDetalle.setHora(cDateTime.substring(11));
		newDetalle.setCodigo("0");
		newDetalle.setCantidad("1");
		//newDetalle.setInsulina(cdoOM.getColValue("insulina"));
		newDetalle.setSiNo(cdoOM.getColValue("siNo"));
		diabLastLineNo++;
		if (diabLastLineNo < 10) key = "00" + diabLastLineNo;
		else if (diabLastLineNo < 100) key = "0" + diabLastLineNo;
		else key = "" + diabLastLineNo;
		try
		{
			iHojaDiab.put(key,newDetalle);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&diabLastLineNo="+diabLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+request.getParameter("desc")+"&fecha_eval="+request.getParameter("fecha"));
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) HojaMgr.add(hoja);
		else if (modeSec.equalsIgnoreCase("edit")) HojaMgr.update(hoja);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (HojaMgr.getErrCode().equals("1"))
{
%>
	alert('<%=HojaMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(HojaMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fecha_eval=<%=request.getParameter("fecha")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>