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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();
String sql    = "";
String mode   = request.getParameter("mode");
String id     = request.getParameter("id");
String empId  = request.getParameter("empId");
String prov   = request.getParameter("prov");
String sig    = request.getParameter("sig");
String tom    = request.getParameter("tom");
String asi    = request.getParameter("asi");
String accion = request.getParameter("accion");
String codigo    = request.getParameter("codigo");
String fg    = request.getParameter("fg");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key    = "";
double desc = 0.4;
boolean viewMode = false;
boolean viewModeS = true;
boolean readonly = true;
int iconHeight = 50;
int iconWidth = 50;
if (mode == null) mode = "add";
if (mode.trim().equals("view")) viewMode = true;
if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		cdo.addColValue("fechaefetiva",cDateTime.substring(0,10));
		cdo.addColValue("salario","");
		cdo.addColValue("salarioSeguro","0");
		cdo.addColValue("salarioCia","0");
		cdo.addColValue("cargo","");
		cdo.addColValue("comentario","");
		cdo.addColValue("horario","");
		cdo.addColValue("desdeSalida","");
		cdo.addColValue("hastaSalida","");
		cdo.addColValue("fechaRetorno","");
		cdo.addColValue("salarioCia","0");
		cdo.addColValue("gastorep","");
		cdo.addColValue("sigla","00");

	}else//		if (mode.equalsIgnoreCase("edit")||mode.equalsIgnoreCase("view"))
	{
		
       sql = "select a.primer_nombre||' '||a.segundo_nombre as nombre, a.primer_apellido||' '||a.segundo_apellido as apellido, a.num_empleado as numempleado,  c.estado, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento cedula, a.provincia, nvl(a.sigla,'')sigla, a.tomo, a.asiento, to_char(a.fecha_ingreso,'dd/month/yyyy') as fechaing,to_char(sysdate,'yyyy') - to_char(a.fecha_ingreso,'yyyy') as anio, to_char(sysdate,'mm') - to_char(a.fecha_ingreso,'mm') as meses, nvl(a.salario_base,0) as salario, to_char(nvl(a.gasto_rep,0),'99,999,990.00') as gastorep, b.denominacion , e.descripcion as depto,c.codigo, c.motivo_falta as tipos, to_char(c.fecha_inicio,'dd/mm/yyyy') as desdeSalida, to_char(c.fecha_final,'dd/mm/yyyy') as hastaSalida, to_char(c.fecha_retorno,'dd/mm/yyyy') as fechaRetorno, to_char(c.fecha_parto,'dd/mm/yyyy') as fechaParto,  c.cant_dias_pagar as diasPagar, c.CANT_QUINCENAS as quincenaSal, c.CANT_MESES as mesSal, c.CANT_DIAS as diaSal, c.tipo_subsidio, decode(tipo_subsidio,'N/A','0.00', nvl(c.salario_actual*.04,0)) salarioCia, to_char(nvl(c.salario_actual,0),'999,999,990.00') as salarioActual, nvl(c.salario_rec_seg,0) as salarioSeguro, c.comentario, f.descripcion as descFalta, a.emp_id from tbl_pla_empleado a, tbl_pla_cargo b, tbl_sec_unidad_ejec e, tbl_pla_cc_licencia c, tbl_pla_motivo_falta f where a.compania = b.compania and a.cargo = b.codigo(+) and a.compania = e.compania and a.ubic_depto = e.codigo and a.emp_id = c.emp_id and a.compania = c.compania and c.motivo_falta = f.codigo(+) and a.compania = "+session.getAttribute("_companyId")+" and a.emp_id = "+empId+" and c.codigo = "+codigo;

	cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title=" Registro de Licencia - "+document.title;
</script>
<script language="javascript">
function calculanor()
{
var hoy;
var edad;
var fecha;
var mes;
var quinc;
var dias;
var mesTot;
var quincTot;
var diasTot;
var salario;

	if (document.form0.desdeSalida.value!="")
	{
	var fechaDesde= document.form0.desdeSalida.value;
	var fechaHasta  = document.form0.hastaSalida.value;

		var valor = splitRowsCols(getDBData('<%=request.getContextPath()%>','round((round(MONTHS_BETWEEN(to_date(\''+fechaHasta+'\',\'dd/mm/yyyy\'),to_date(\''+fechaDesde+'\',\'dd/mm/yyyy\')),1) *2 ),0)quincenas,TRUNC(MONTHS_BETWEEN(to_date(\''+fechaHasta+'\',\'dd/mm/yyyy\'),to_date(\''+fechaDesde+'\',\'dd/mm/yyyy\')),0) meses,to_date(\''+fechaHasta+'\',\'dd/mm/yyyy\') - (ADD_MONTHS(to_date(\''+fechaDesde+'\',\'dd/mm/yyyy\'),TRUNC(MONTHS_BETWEEN(to_date(\''+fechaHasta+'\',\'dd/mm/yyyy\'),to_date(\''+fechaDesde+'\',\'dd/mm/yyyy\')),0))) dias ','dual','',''));

 		document.form0.quincenaSal.value=valor[0][0];
		document.form0.mesSal.value=valor[0][1];
		document.form0.diasSal.value=valor[0][2];
		document.form0.quinc.value=valor[0][0];
		document.form0.mes.value=valor[0][1];
		document.form0.dia.value=valor[0][2];
	}
}

			 

function validaFecha()
{
var hoy;
var fecha;
var desde;
var mesTot;
var quincTot;
var diasTot;
var salario;
var retorno;

	if ((document.form0.desdeSalida.value!="")  && (document.form0.fechaRetorno.value!=""))
	{
	hoy   = new Date() ;
	fecha = new Date() ;
	desde = new Date() ;

	fecha= document.form0.hastaSalida.value;
	hoy  = document.form0.fechaRetorno.value;
	retorno  = document.form0.fechaRetorno.value;

	var array_hoy   = hoy.split("/") ;
	var array_fecha   = hoy.split("/") ;
	var con    = parseInt(0);
	var diaval;
   		diaval = parseInt(array_hoy[0]);
	var meshoy ;
    	meshoy = parseInt(array_hoy[1]);
	var anioval;
   		anioval = parseInt(array_hoy[2]);
		meshoy = retorno.substring(3,5);

		var difdia = getDBData('<%=request.getContextPath()%>','(to_date(\''+retorno+'\',\'dd/mm/yyyy\') - to_date(\''+fecha+'\',\'dd/mm/yyyy\')) as fecha','dual','','');
	 	document.form0.diasPagar.value=diaval;

	if(difdia <= 0)
	{
	alert('Fecha de Retorno no puede ser MENOR o IGUAL a la fecha de inicio/fín de la transacción.. Verifique !');
		document.form0.fechaRetorno.value="";
		document.form0.diasPagar.value="";
		return false;
	}
	/// alert('Valor asigando  '+meshoy+' diaval '+diaval+'  anioval '+anioval);
    if(diaval>=16)
	 {
	 mes = meshoy * 2 ;
	 }
	 else {
	 mes = (meshoy * 2 ) - 1;
	 }
			 //var dias = getDBData('<%=request.getContextPath()%>','to_date(to_char(nvl(case when to_number(to_char(to_date(\''+retorno+'\',\'dd/mm/yyyy\'),\'dd\'))between 1 and 15 then(select fecha_final from tbl_pla_calendario where periodo=(to_number(to_char(to_date(\''+retorno+'\',\'dd/mm/yyyy\'),\'MM\'))*2)-1 and tipopla = 1)else(select fecha_final from tbl_pla_calendario where periodo=(to_number(to_char(to_date(\''+fechaRetorno+'\',\'dd/mm/yyyy\'),\'MM\'))*2) and tipopla=1) end,sysdate),\'dd/mm\')||'/'||'/'||to_char(to_date(\''+fechaRetorno+'\','dd/mm/YYYY'),'YYYY'),'DD/MM/YYYY') - to_date(\''+fechaRetorno+'\','dd/mm/YYYY') fechafin','dual','','');

	 var diaEntre=getDBData('<%=request.getContextPath()%>','to_char(fecha_final,\'dd/mm\')','tbl_pla_calendario','periodo= \''+mes+'\' and tipopla=\'1\'','');

	   diaEntre = diaEntre + '/' + anioval ;
		 var difPer = getDBData('<%=request.getContextPath()%>','(to_date(\''+diaEntre+'\',\'dd/mm/yyyy\') - to_date(\''+hoy+'\',\'dd/mm/yyyy\')) as fecha','dual','','');

		 if (difPer>=0)
		 {
		     document.form0.diasPagar.value=difPer;
			}	 else { document.form0.diasPagar.value=0; 	}


	} else
	{
	alert('Falta Registro de Fecha de Datos de Salida !');
	document.form0.fechaRetorno.value="";
	document.form0.diasPagar.value="";


	}
}

function tipoSubsidio()
{
	var subsidio = "" ;
	var ctrl = document.form0.tipos.value;
	subsidio= document.form0.tiposubsidio.value;
	if((subsidio!="N/A") && (ctrl!="37"))
	{
		document.form0.salarioSeguro.readOnly = false;
		document.form0.salarioSeguro.className = 'FormDataObjectEnabled';
		document.form0.salarioSeguro.value = "0.00";
		document.form0.salario.readOnly = false;
		document.form0.salario.value = "0.00";
		document.form0.salario.className = 'FormDataObjectEnabled';
		document.form0.salarioCia.value = "0.00";

	} else
	{
		document.form0.salarioSeguro.readOnly = true;
		document.form0.salarioSeguro.value = "0.00";
		document.form0.salarioSeguro.className = 'FormDataObjectDisabled';
		document.form0.salario.readOnly = true;
		document.form0.salario.value = "0.00";
		document.form0.salario.className = 'FormDataObjectDisabled';
		document.form0.salarioCia.value = "0.00";

		if (ctrl=="37") document.form0.tiposubsidio.value = "N/A";
	}
}

function displayFields()
{
	var subsidio = "" ;
	var ctrl = document.form0.tipos.value;
	subsidio= document.form0.tiposubsidio.value;
	if(ctrl=="37")
	{
		document.form0.fechaParto.readOnly = false;
		document.form0.fechaParto.className = 'FormDataObjectEnabled';
		document.form0.resetfechaParto.disabled = false;
		if (subsidio!="N/A")
		{
			document.form0.tiposubsidio.value = "N/A";
			document.form0.salarioSeguro.readOnly = true;
			document.form0.salarioSeguro.className = 'FormDataObjectDisabled';
			document.form0.salarioSeguro.value = "0.00";
			document.form0.salario.readOnly = true;
			document.form0.salario.value = "0.00";
			document.form0.salario.className = 'FormDataObjectDisabled';
			document.form0.salarioCia.value = "0.00";
		}
	}	else {
		document.form0.fechaParto.readOnly = true;
		document.form0.fechaParto.className = 'FormDataObjectDisabled';
		document.form0.resetfechaParto.disabled = true;
		document.form0.fechaParto.value = "";
	}
}

function salCia()
{
	var monto = document.form0.salario.value;
	var subsidio= document.form0.tiposubsidio.value;
	if(subsidio!="N/A")
	{
	document.form0.salarioCia.value = (monto * 0.4);
	}
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function doAction(){displayFields();document.form0.salario.value=document.empleado.salario_mes.value;
setEmpledoInfo('form0');}
function distribuir()
{
var quincenaSal = document.form0.quincenaSal.value;
var fechaDesde = document.form0.desdeSalida.value;
var fechaHasta = document.form0.hastaSalida.value;

abrir_ventana('../rhplanilla/distribuir_licencia.jsp?mode=<%=mode%>&empId=<%=empId%>&quincenas='+quincenaSal+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta+'&provincia=<%=cdo.getColValue("provincia")%>&sigla=<%=cdo.getColValue("sigla")%>&tomo=<%=cdo.getColValue("tomo")%>&asiento=<%=cdo.getColValue("asiento")%>&codigo=<%=cdo.getColValue("codigo")%>');
}
function doSubmit(baction)
{ document.form0.baction.value = baction;
var quincenaSal = document.form0.quincenaSal.value;
var fechaDesde = document.form0.desdeSalida.value;
var fechaHasta = document.form0.hastaSalida.value;

setEmpledoInfo('form0');
var empId = document.form0.empId.value;

if(empId ==''){alert('Seleccion empleado');}else{
if (!form0Validation()){ return false;}
  else{ if(fechaDesde !=''&&fechaDesde !=''){document.form0.submit();}else{alert('Introduzca fecha de Inicio/ final');}}
}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - TRANSACCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="99%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
		<tr>
			<td>
			<jsp:include page="../common/empleado.jsp" flush="true">
			<jsp:param name="empId" value="<%=empId%>"></jsp:param>
			<jsp:param name="fp" value="licencia"></jsp:param>
			<jsp:param name="mode" value="<%=mode%>"></jsp:param>
			</jsp:include>
			</td>
		</tr>

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("quinc",cdo.getColValue("quincenaSal"))%>
<%=fb.hidden("mes",cdo.getColValue("mesSal"))%>
<%=fb.hidden("dia",cdo.getColValue("diaSal"))%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("empId","")%>
<%=fb.hidden("provincia",""+prov)%>
<%=fb.hidden("sigla",""+sig)%>
<%=fb.hidden("tomo",""+tom)%>
<%=fb.hidden("asiento",""+asi)%>
<%=fb.hidden("baction","")%>

 <tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">

		<tr>
		<td><div id="panel0" style="visibility:visible;">
		<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
		
        <tr class="TextHeader">
                <td colspan="4">Motivos de Salida  </td>
        </tr>

      	<tr class="TextRow01">
			<td>Motivo de Falta </td>
			<td> <%=fb.select("tipos","35=INCAPACIDAD,13=ENFERMEDAD,37=LICENCIA POR GRAVIDEZ,40=LICENCIA CON SUELDO,38=LICENCIA SIN SUELDO,39= RIESGO PROFESIONAL ",cdo.getColValue("tipos"),false,false,0,null,null,"onChange=\"javascript:displayFields()\"")%></td>

			<td>Fecha Probable de Parto: &nbsp;
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fechaParto" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fechaParto") != null && !cdo.getColValue("fechaParto").trim().equals("")?cdo.getColValue("fechaParto"):"")%>" />
 			  </jsp:include>
 			</td>
			<td>Tipo de Subsidio : &nbsp;&nbsp; <%=fb.select("tiposubsidio","N/A= NO APLICA , RPR=RIESGO PROFESIONAL, ANP=ACCIDENTE NO PROFESIONAL, ENF=ENFERMEDAD ",cdo.getColValue("tipo_subsidio"),false,false,0,null,null,"onChange=\"javascript:tipoSubsidio()\"")%></td>

      </tr>

      <tr class="TextHeader">
          <td colspan="2" align="center">Datos de Salida  </td>
          <td align="center">Datos de Retorno  </td>
          <td class="TextRow01">Salario Actual : <%=fb.decBox("salario", (cdo.getColValue("salario")!=null && !cdo.getColValue("salario").trim().equals(""))?(cdo.getColValue("salario")):"",false,false,viewMode,10)%></td>
			</tr>

      	<tr class="TextRow01">
					<td colspan="2">Desde	<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="desdeSalida" />
							<jsp:param name="fieldClass" value="FormDataObjectRequired" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("desdeSalida")%>" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
							</jsp:include>	&nbsp; Hasta  :  &nbsp;
					   		 <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="hastaSalida" />
								<jsp:param name="fieldClass" value="FormDataObjectRequired" />
						 		<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hastaSalida")%>" />
							    <jsp:param name="jsEvent" value="calculanor()" />
							    <jsp:param name="onChange" value="calculanor();" />
							    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
								</jsp:include>
						</td>
         		 <td>Fecha de Retorno : &nbsp;&nbsp;
         		 			<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="fechaRetorno" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaRetorno")%>" />
							<jsp:param name="jsEvent" value="validaFecha()" />
							<jsp:param name="onChange" value="validaFecha();" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
             				</jsp:include></td>
           	<td>Salario Seguro : &nbsp;&nbsp;<%=fb.decBox("salarioSeguro",(cdo.getColValue("salarioSeguro")!=null && !cdo.getColValue("salarioSeguro").trim().equals(""))?CmnMgr.getFormattedDecimal(cdo.getColValue("salarioSeguro")):"",false,false,viewMode,10,10.2,null,null,"onBlur=\"javascript:salCia()\"")%></td>
					</tr>
      	<tr class="TextRow01">
							<td colspan="2">Quincenas : &nbsp;&nbsp; <%=fb.intBox("quincenaSal",cdo.getColValue("quincenaSal"),true,false,true,4)%>
								&nbsp; &nbsp; Meses :&nbsp;&nbsp;<%=fb.intBox("mesSal",cdo.getColValue("mesSal"),true,false,true,4)%>&nbsp;Días :&nbsp;&nbsp;<%=fb.intBox("diasSal",cdo.getColValue("diaSal"),true,true,false,4)%>
							</td>
							<td> Cantidad de Días a Pagar : &nbsp;<%=fb.intBox("diasPagar",cdo.getColValue("diasPagar"),false,false,false,4)%></td>


							<td>% Salario Cía: &nbsp;&nbsp;&nbsp;&nbsp;<%=fb.decBox("salarioCia",(cdo.getColValue("salarioCia")!=null && !cdo.getColValue("salarioCia").trim().equals(""))?CmnMgr.getFormattedDecimal("#####0.00",cdo.getColValue("salarioCia")):"",false,false,viewMode,10,10.2,null,null,"","",false,"")%></td>

			</tr>

			<tr class="TextRow01">
					<td>Observaciones : </td>
					<td colspan="2"><%=fb.textarea("comentario",cdo.getColValue("comentario"),false,false,viewMode,90,3)%></td>
					<td align="center"><%if(!mode.trim().equals("add")/* && fg.trim().equals("DIST")*/){%><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/distribute.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:distribuir()"><%}%></td>
			</tr>


			</table>
			</div>
  </td>
</tr>
		</table>
	</td>
	</tr>

	<tr class="TextRow02">
	<td align="right">
	<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"","")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	<tr>
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

	id   = request.getParameter("id");
	codigo  = request.getParameter("codigo");
	mode = request.getParameter("mode");
	prov = request.getParameter("provincia");
	sig  = request.getParameter("sigla");
	tom  = request.getParameter("tomo");
	asi  = request.getParameter("asiento");
	empId  = request.getParameter("empId");
	System.out.println(" provincia ==== "+request.getParameter("provincia"));

System.out.println(" empId ==== "+request.getParameter("empId"));
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_pla_cc_licencia");
	
	if (request.getParameter("desdeSalida") == null || request.getParameter("desdeSalida").equals("") || request.getParameter("hastaSalida") == null || request.getParameter("hastaSalida").equals("")||(request.getParameter("empId") == null || request.getParameter("empId").trim().equals(""))){
 response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&empId="+empId);
      return;
} else {
	if (request.getParameter("desdeSalida") != null)
	cdo.addColValue("fecha_inicio",request.getParameter("desdeSalida"));
	if (request.getParameter("hastaSalida") != null)
	cdo.addColValue("fecha_final",request.getParameter("hastaSalida"));
	if (request.getParameter("tipos") != null)
	cdo.addColValue("motivo_falta",request.getParameter("tipos"));
	if (request.getParameter("tiposubsidio") != null)
	cdo.addColValue("tipo_subsidio",request.getParameter("tiposubsidio"));
	//if (request.getParameter("quincenaSal") != null)
	cdo.addColValue("cant_quincenas",request.getParameter("quinc"));
	//if (request.getParameter("mesSal") != null)
	cdo.addColValue("cant_meses",request.getParameter("mes"));
	//if (request.getParameter("diasSal") != null)
	cdo.addColValue("cant_dias",request.getParameter("dia"));

	if (request.getParameter("salario") != null)
	cdo.addColValue("salario_actual",request.getParameter("salario"));
	if (request.getParameter("salarioSeguro") != null)
	cdo.addColValue("salario_rec_seg",request.getParameter("salarioSeguro"));
	if (request.getParameter("fechaRetorno") != null)
	cdo.addColValue("fecha_retorno",request.getParameter("fechaRetorno"));
	if (request.getParameter("diasPagar") != null || !request.getParameter("diasPagar").equals(""))
	cdo.addColValue("cant_dias_pagar",request.getParameter("diasPagar"));
	if (request.getParameter("comentario") != null)
	cdo.addColValue("comentario",request.getParameter("comentario"));
	if (request.getParameter("fechaParto") != null || !request.getParameter("fechaParto").equals(""))
	cdo.addColValue("fecha_parto",request.getParameter("fechaParto"));

	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",cDateTime);
	cdo.addColValue("estado","P");

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));

		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("empId"));
		cdo.setAutoIncCol("codigo");
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("provincia",prov);
		cdo.addColValue("sigla",sig);
		cdo.addColValue("tomo",tom);
		cdo.addColValue("asiento",asi);
		cdo.addColValue("emp_id",empId);
		SQLMgr.insert(cdo);
	}
	else
	{

	  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id ="+request.getParameter("empId")+" and codigo="+request.getParameter("codigo"));
		SQLMgr.update(cdo);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/licencia_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/licencia_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/licencia_list.jsp';
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