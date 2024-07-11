<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.EscalaComa"%>
<%@ page import="issi.expediente.DetalleResultadoEscala"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashEsc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaComaMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
EscalaComa escComa = new EscalaComa();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String fp = "";
String subTitle ="ESCALA GLASGOW";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "A";
if (fg.trim().equals("A")){ subTitle += " - ADULTO"; fp="E";}
else if (fg.trim().equals("N")){ subTitle += " - NIÑOS";fp="P";}

boolean checkDefault = false;
int rowCount = 0;
String fecha_eval = request.getParameter("fecha_eval");
String hora_eval = request.getParameter("hora_eval");
int escLastLineNo = 0;
String appendFilter="" , op = "";
String key = "";
int eTotal=0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	

HashEsc.clear();
sql="select to_char(fecha_recup,'dd/mm/yyyy') as fecha_recup, to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora , total as total, usuario_recup from tbl_sal_escala_coma  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and tipo ='"+fg+"' order by fecha desc, hora desc";
al2= SQLMgr.getDataList(sql);
escLastLineNo = al2.size();
			for (int i=1; i<=al2.size(); i++)
			{
						cdo = (CommonDataObject) al2.get(i-1);
						if (i < 10) key = "00" + (i-1);
						else if (i < 100) key = "0" + (i-1);
						else key = "" + i;
						cdo.addColValue("key",key);
						if(cdo.getColValue("fecha").equals(cDateTime.substring(0,10)) && cdo.getColValue("hora").equals(cDateTime.substring(11,12)))
						{
						cdo.addColValue("OBSERVACION","Evaluacion actual ");
							op = "0";
							modeSec="edit";
							if(!viewMode)viewMode= false;

						}else
						{cdo.addColValue("OBSERVACION","Evaluacion "+ (1+escLastLineNo - i));
								appendFilter = "1";
						}
						try
						{
							HashEsc.put(key, cdo);
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
			}//for
			if(al2.size() == 0 )
			{
					cdo = new CommonDataObject();
					cdo.addColValue("FECHA",cDateTime.substring(0,10));
					cdo.addColValue("Hora",cDateTime.substring(11));
					cdo.addColValue("total","----");
					cdo.addColValue("OBSERVACION","Evaluacion Actual");
					escLastLineNo++;
					if (escLastLineNo < 10) key = "00" + escLastLineNo;
					else if (escLastLineNo < 100) key = "0" + escLastLineNo;
					else key = "" + escLastLineNo;
					cdo.addColValue("key",key);
					op = "0";
					try
					{
						HashEsc.put(key, cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
			}

if(fecha_eval != null )//|| fecha_eval.trim().equals("")
{
		if(fecha_eval.equals(cDateTime.substring(0,10)) && hora_eval.equals(cDateTime.substring(11))){
			modeSec="edit";
			if(!viewMode)viewMode= false;
		}

	}
	else	{

		fecha_eval = cDateTime.substring(0,10);
		hora_eval = cDateTime.substring(11);
		if (!viewMode)modeSec = "edit";
		//viewMode= false;
}

sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, evaluacion_derecha as evaluacionDerecha, evaluacion_izquierda as evaluacionIzquierda, observacion as observacion , to_char(fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(hora_registro,'hh12:mi:ss am') as horaRegistro, total as total from tbl_sal_escala_coma  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha_eval+"','dd/mm/yyyy') and  to_date(to_char(hora,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+hora_eval+"','hh12:mi:ss am')  and tipo ='"+fg+"' ";

escComa = (EscalaComa) sbb.getSingleRowBean(ConMgr.getConnection(),sql,EscalaComa.class);

		if(escComa == null)
		{
				escComa = new EscalaComa();
				escComa.setHora(cDateTime.substring(11));
				escComa.setFecha(cDateTime.substring(0,10));
				escComa.setTotal("0");
				escComa.setEvaluacionDerecha("1");
				escComa.setEvaluacionIzquierda("1");
		}
		//System.out.println("hora_eval   ---"+hora_eval);
		sql = "SELECT nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.FECHA_ESCALA, b.HORA_ESCALA , b.OBSERVACION as observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM TBL_SAL_TIPO_ESCALA a, (SELECT nvl(TIPO_ESCALA ,0)as tipo_escala, nvl(DETALLE,0)as detalle, FECHA_ESCALA, HORA_ESCALA, OBSERVACION, VALOR, APLICAR FROM TBL_SAL_RESULTADO_ESCALA  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha_escala,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha_eval+"','dd/mm/yyyy') and  to_date(to_char(hora_escala,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+hora_eval+"','hh12:mi:ss pm') order by 1,2) b where a.codigo=b.tipo_escala(+) and a.tipo = '"+fg+"' and a.estado ='A' union SELECT a.tipo_escala,a.codigo, 0, a.descripcion, a.escala,null, null, null ,0, '' FROM TBL_SAL_DETALLE_ESCALA a,(select nvl(TIPO_ESCALA,0) as tipo_escala  from TBL_SAL_RESULTADO_ESCALA a where pac_id = "+pacId+" and secuencia = "+noAdmision+" order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo='"+fg+"' and a.estado ='A' ORDER BY 1,2";

		 al = SQLMgr.getDataList(sql);
		 
		 
%>
<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
<!--Para mas Informacion leer (info_v3.txt)-->
<!--Done by. eduardo.b@issi-panama.com-->
<!DOCTYPE html>
<html lang="en">   
<!--comienza el head-->    
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
document.title = 'ESCALA GLASGOW - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verEscala(k,mode){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;var hora_e = eval('document.form0.hora_evaluacion'+k).value ;window.location = '../expediente3.0/exp_escala_glasgow.jsp?&modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e+'&hora_eval='+hora_e;}
function doAction(){checkViewMode();}
function setEscalaValor(k,codigo,valor){
    var vIni = eval('document.form0.valIni').value;
    if(vIni == "1"){
        //eval('document.form0.total2').value = "0";
        eval('document.form0.valIni').value = "0";
        distValor(k);
        sumaEscala();
    }
    eval('document.form0.opcion').value = "1";
    // eval('document.form0.total2').value = parseInt(eval('document.form0.total2').value )-parseInt(eval('document.form0.valor'+k).value );
    sumaEscala();
    document.getElementById("valor"+k).value = valor;
    document.getElementById("codDetalle"+k).value = codigo;
    //eval('document.form0.total2').value = parseInt(eval('document.form0.total2').value )+parseInt(valor);
    sumaEscala();
}
function distValor(j){var size1 = parseInt(document.getElementById("size").value);for (i=1;i<=size1;i++){if(i!=j)document.getElementById("escala"+j).checked = false;}eval('document.form0.opcion').value = "1";}

function sumaEscala(){
    var total = 0;
    $(".radio-escala:checked").each(function(){
        var self = $(this);
        total += parseInt(self.data('value'));
    });
    if(!<%=viewMode%>) $("#total2").val(total);
    $('#valIni').val("1");
}

function sumaEscala1(){
    var total = 0;
    for (i=1;i<=parseInt(document.getElementById("size").value);i++){
        total = total + parseInt(document.getElementById("valorL"+i).value);
    }
    if(!<%=viewMode%>)document.getElementById("total2").value = total;
    eval('document.form0.valIni').value = "1";
    alert(total)
}
function setAlert(){alert('No se ha realizado la evaluación');}
function printEscala(option){
  var fecha = document.form0.fecha.value;
  var hora = document.form0.hora.value;
  if(!option)abrir_ventana1('../expediente/print_escala_glasgow.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&fechaEscala='+fecha+'&horaEscala='+hora);
  else abrir_ventana1('../expediente/print_escala_glasgow.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=modeSec%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>');
  }
function eTrauma(){if (window.estadoAtencion != "F"){parent.setPatientInfo('form0','iDetalle');var fecha = document.form0.fecha.value;var hora = document.form0.hora.value;var dob = document.form0.dob.value;var codPac = document.form0.codPac.value;var flag = false;var mode = '<%=modeSec%>';if (mode != 'view') flag = false;var viewMode = '';var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_escala_coma','fecha = to_date(\''+fecha+'\',\'dd/mm/yyyy\') and hora = to_date(\'01/\'||to_char(fecha,\'mm/yyyy\')||\' '+hora+'\',\'dd/mm/yyyy hh12:mi:ss am\') and pac_id = <%=pacId%> and secuencia = <%=noAdmision%>',''));var r1=splitRowsCols(getDBData('<%=request.getContextPath()%>','to_char(fecha_trauma,\'dd/mm/yyyy\') FT, to_char(hora,\'hh12:mi:ss am\') HT','tbl_sal_escala_coma','fecha_trauma = to_date(\''+fecha+'\',\'dd/mm/yyyy\') and hora_trauma = to_date(\'01/\'||to_char(hora_registro,\'mm/yyyy\')||\' '+hora+'\',\'dd/mm/yyyy hh12:mi:ss am\') and pac_id = <%=pacId%> and secuencia = <%=noAdmision%>','group by to_char(fecha_trauma,\'dd/mm/yyyy\'), to_char(hora,\'hh12:mi:ss am\')'));var fechaEval = "";var horaEval  = "";if ( r > 0 ){if (r1 != null ){fechaEval = r1[0][0];horaEval  = r1[0][1];viewMode = 'view';alert("Esta escala ya ha sido evaluada, la pantalla se abrirá en modo de lectura!");flag = true;}else{viewMode = "";flag = true;}}else if ( mode != 'view' ){alert("Usted tiene que crear o seleccionar la escala de Glasgow antes de evaluarla!");flag = false;}else{alert("Usted tiene que crear o seleccionar la escala de Glasgow antes de evaluarla!");flag = false;}if(flag) abrir_ventana1('../expediente/exp_evaluacion_trauma.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&fp=<%=fp%>&fechaEscala='+fecha+'&horaEscala='+hora+'&dob='+dob+'&codPac='+codPac+'&mode=<%=mode%>&modeSec='+viewMode+'&fechaEval='+fechaEval+'&horaEval='+horaEval);}}
function add(){	window.location = "../expediente3.0/exp_escala_glasgow.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&modeSec=add&fg=<%=fg%>";}

$(function(){
    <%if(!modeSec.equalsIgnoreCase("view")){%>
        $(".cod-tipo-escala").each(function(){
           var self = $(this);
           var h = self.data("hndex");
           $( 'input[name="escala'+h+'"]:radio:first' ).click();
           setValor();
        });
    <%}%>
    $(".radio-escala").click(function(){
        var self = $(this);
        var i = self.data("index");
        var val = self.data("value");
        
        $("#valor"+i).val(val);
        sumaEscala();
    });
    
});

function setValor() {
    $(".radio-escala").each(function(){
        var self = $(this);
        if(self.is(":checked")){
        var i = self.data("index");
        var val = self.data("value");
        
        $("#valor"+i).val(val);
        }
    });
    sumaEscala();
}
</script>
</head>
<!--termina el head-->  

<!--comienza el cuerpo del sitio-->  
<body class="body-forminside">

    <!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->    
<!--INICIO de una fila de elementos-->    
<div class="row">
<!--INICIO de una fila de elementos-->

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("opcion","0")%>
<%=fb.hidden("valIni","0")%>

    <div class="headerform2">
<!--tabla de boton imprimit-->
<table class="table table-small-font table-bordered table-striped table-custom-2">
    <tr class="text-right">
        <td>
        <% if (!mode.trim().equals("view")){ %>
    <button onclick="add()" type="button" class="btn btn-inverse btn-sm"><i class="fa fa-plus fa-printico"></i> <b>Agregar</b></button><%}%>
    <button onclick="eTrauma()" type="button" class="btn btn-inverse btn-sm"><i class="fa fa-user-md fa-printico"></i> <b>Eval. Trauma</b></button>
    <%if(HashEsc.size() > 1){%>
    <button onclick="printEscala(1)" type="button" class="btn btn-inverse btn-sm"><i class="material-icons fa-printico">print</i> <b>Imprimir Todas</b></button>
    <%}%>
    
    <%if (request.getParameter("fecha_eval") != null){%>
    <button onclick="printEscala()" type="button" class="btn btn-inverse btn-sm"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
    <%}%>
    </td>

    </tr>
    <tr>
    <td class="bg-headtabla"><div class="pull-left"><b>LISTADO DE EVALUACIONES ESCALA GLASGOW DEL COMA</b></div>
    </td>
   </tr>

    
    </table>
<!--fin tabla de boton imprimit-->
<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped" style="margin-bottom:0px !important;">
<thead>
    
    <tr class="bg-headtabla2" >
    <th style="vertical-align: middle !important;">Fecha</th>
    <th style="vertical-align: middle !important;">Hora</th>
    <th style="vertical-align: middle !important;">Puntos</th>
    <th style="vertical-align: middle !important;">Observación</th>
    <th style="vertical-align: middle !important;">Fecha Recup.</th>
   </tr>
   
   <%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
        <%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
        <%=fb.hidden("hora_evaluacion0",cDateTime.substring(11))%>
        <tr class="bg-headtabla" style="cursor:pointer " onClick="javascript:verEscala(0,'add')" >
            <td><%=cDateTime.substring(0,10)%></td>
            <td><%=cDateTime.substring(11)%></td>
            <td>----</td>
            <td><cellbytelabel id="6">Evaluaci&oacute;n actual</cellbytelabel></td>
            <td>----</td>
        </tr>
<%}%>
   
   
    </thead>
<tbody>

<% al2 = CmnMgr.reverseRecords(HashEsc);
for (int i=1; i<=HashEsc.size(); i++){
	key = al2.get(i-1).toString();
	cdo = (CommonDataObject) HashEsc.get(key);
	%>

		<%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("hora_evaluacion"+i,cdo.getColValue("hora"))%>

		<tr style="cursor:pointer " onClick="javascript:verEscala(<%=i%>,'view')">
            <td><%=cdo.getColValue("fecha")%></td>
            <td><%=cdo.getColValue("hora")%></td>
            <td><%=cdo.getColValue("total")%></td>
            <td><%=cdo.getColValue("observacion")%></td>
            <td><%=cdo.getColValue("fecha_recup"," ")%></td>
		</tr>
<%}%>

</tbody>
</table>
</div>
    </div>
    
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <tbody>
    
    <tr class="text-left">
        <td style="vertical-align: middle !important;" class="controls form-inline">
            Fecha:&nbsp;<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="valueOfTBox1" value="<%=escComa.getFecha()%>" />
            <jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>" />
            </jsp:include>
        </td>
        <td style="vertical-align: middle !important;" class="controls form-inline">
            Hora:&nbsp;<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="hh12:mi:ss am"/>
            <jsp:param name="nameOfTBox1" value="hora" />
            <jsp:param name="valueOfTBox1" value="<%=escComa.getHora()%>" />
            <jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>" />
            </jsp:include>
        </td>
        
        <td style="vertical-align: middle !important;">
            <!--tabla de Evaluacion Pupilar-->
            
                
            <table class="pull-left">
                <div class="text-left" style="vertical-align: middle !important"><b>Evaluación Pupilar:</b></div>
                <tr>
                    <td>&nbsp;</td>
                    <td class="text-center">1</td>
                    <td class="text-center">2</td>
                    <td class="text-center">3</td>
                    <td class="text-center">4</td>
                    <td class="text-center">5</td>
                    <td class="text-center">6</td>
                    <td class="text-center">7</td>
                    <td class="text-center">8</td>
                    <td class="text-center">9</td>
                </tr>
                <tr>
                <td></td>
                <td class="text-center"><div class="round round-sm">1mm</div></td>
                <td class="text-center"><div class="round round-sm">2mm</div></td>
                <td class="text-center"><div class="round round-sm1">3mm</div></td>
                <td class="text-center"><div class="round round-sm2">4mm</div></td>
                <td class="text-center"><div class="round round-sm3">5mm</div></td>
                <td class="text-center"><div class="round round-sm4">6mm</div></td>
                <td class="text-center"><div class="round round-sm5">7mm</div></td>
                <td class="text-center"><div class="round round-sm6">8mm</div></td>
                <td class="text-center"><div class="round round-sm7">9mm</div></td>
                </tr>
                <tr>
                    <td><small>Derecha:</small></td>
                    <td class="text-center"><%=fb.radio("derecha","1",escComa.getEvaluacionDerecha().equals("1"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","2",escComa.getEvaluacionDerecha().equals("2"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","3",escComa.getEvaluacionDerecha().equals("3"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","4",escComa.getEvaluacionDerecha().equals("4"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","5",escComa.getEvaluacionDerecha().equals("5"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","6",escComa.getEvaluacionDerecha().equals("6"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","7",escComa.getEvaluacionDerecha().equals("7"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","8",escComa.getEvaluacionDerecha().equals("8"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("derecha","9",escComa.getEvaluacionDerecha().equals("9"),viewMode,false)%></td>
                    
                </tr>
                <tr>
                    <td><small>Izquierda:</small></td>
                    <td class="text-center"><%=fb.radio("izquierda","1",escComa.getEvaluacionIzquierda().equals("1"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","2",escComa.getEvaluacionIzquierda().equals("2"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","3",escComa.getEvaluacionIzquierda().equals("3"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","4",escComa.getEvaluacionIzquierda().equals("4"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","5",escComa.getEvaluacionIzquierda().equals("5"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","6",escComa.getEvaluacionIzquierda().equals("6"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","7",escComa.getEvaluacionIzquierda().equals("7"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","8",escComa.getEvaluacionIzquierda().equals("8"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("izquierda","9",escComa.getEvaluacionIzquierda().equals("9"),viewMode,false)%></td>
                </tr>
            </table>
            <!-- Fin tabla de Evaluacion Pupilar-->
            </td>

    </tr>
    
    <tr class="bg-headtabla text-left">
        <td><b>Funciones Neurológicas</b></td>
        <td><b>Escala</b></td>
        <td><b>Observación</b></td>
    </tr>
    
    <%
    int totalD = 0;
    String observ = "";
    ArrayList alH = SQLMgr.getDataList("select codigo, descripcion, (select observacion from tbl_sal_resultado_escala where tipo_escala = codigo and pac_id = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(hora_escala,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+hora_eval+"','hh12:mi:ss pm') and to_date(to_char(fecha_escala,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha_eval+"','dd/mm/yyyy') and rownum = 1  ) observacion from tbl_sal_tipo_escala where tipo = '"+fg+"' and estado = 'A'");
    
    for (int h = 0; h < alH.size(); h++) {
        CommonDataObject cdoH = (CommonDataObject) alH.get(h);
        sql = "select de.codigo, b.detalle, de.tipo_escala, b.tipo_escala tipo_escala_det, de.descripcion ,b.fecha_escala, b.hora_escala , b.observacion as observacion, b.valor, b.aplicar, de.escala from tbl_sal_detalle_escala de ,(select tipo_escala, detalle, fecha_escala, hora_escala, observacion, valor, aplicar, tipo from tbl_sal_resultado_escala  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha_escala,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha_eval+"','dd/mm/yyyy') and  to_date(to_char(hora_escala,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+hora_eval+"','hh12:mi:ss pm') order by 1,2) b where de.tipo = '"+fg+"' and de.tipo_escala = "+cdoH.getColValue("codigo")+" and de.estado = 'A' and de.tipo_escala = b.tipo_escala(+) and de.codigo = b.detalle(+) and de.tipo = b.tipo(+) order by de.tipo_escala, de.codigo";
        ArrayList alD = SQLMgr.getDataList(sql);
    %>
        <%=fb.hidden("tipo_escala"+h, cdoH.getColValue("codigo"))%>
        <input type="hidden" class="cod-tipo-escala" value="<%=cdoH.getColValue("codigo")%>" data-hndex="<%=h%>">
        <%=fb.hidden("valor"+h, "")%>
        <tr>
            <td>[<%=cdoH.getColValue("codigo")%>]&nbsp;<%=cdoH.getColValue("descripcion")%></td>
            <td>
                <table class="pull-left">
                <% for (int d = 0; d < alD.size(); d++) {
                        CommonDataObject cdoD = (CommonDataObject) alD.get(d);
                        
                        boolean check = (cdoD.getColValue("codigo").equals(cdoD.getColValue("detalle"))) && (cdoD.getColValue("tipo_escala").equals(cdoD.getColValue("tipo_escala_det")));
                        
                        // if (!modeSec.equalsIgnoreCase("view")) check = true;
                %>
                    <tr>
                        <td width="95%">
                            <label class="pointer">
                            <%=fb.radio("escala"+h, cdoD.getColValue("codigo"),check,viewMode, false ,"radio-escala checks-group-"+cdoH.getColValue("codigo"), "", "",null," data-index="+h+" data-value="+cdoD.getColValue("escala"))%>
                            &nbsp;
                            <%=cdoD.getColValue("descripcion")%>
                            </label>
                        </td>
                        <td>[<%=cdoD.getColValue("escala")%>]</td>
                    </tr>
                <%
                    totalD++;
                   }
                %>
                </table>
            </td>
            <td>
                <%=fb.textarea("observacion"+h,cdoH.getColValue("observacion"),false,false,viewMode,30,0,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
    <%
    }
    %>
    <%=fb.hidden("total_h", ""+alH.size())%>
    <%=fb.hidden("total_d", ""+totalD)%>
<tr class="TextRow02">
<td>&nbsp;</td>
<td align="right" class="controls form-inline">Total:<%=fb.intBox("total2",""+escComa.getTotal()+"",false,false,true,2,0,"form-control input-sm",null,null)%></td>
<td>&nbsp;</td>
</tr>
 
 <div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
        <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> </div> 

<%=fb.formEnd(true)%>
<script type="text/javascript">sumaEscala();</script>
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
	int size = 0;
	int tpuntos=0;
	fecha_eval = request.getParameter("fecha");
	hora_eval = request.getParameter("hora");
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
    
    int totalH = Integer.parseInt(request.getParameter("total_h"));
    int totalD = Integer.parseInt(request.getParameter("total_d"));

	EscalaComa eco = new EscalaComa();
	eco.setCodPaciente(request.getParameter("codPac"));
	eco.setFecNacimiento(request.getParameter("dob"));
	eco.setSecuencia(request.getParameter("noAdmision"));
	eco.setPacId(request.getParameter("pacId"));
	eco.setFecha(request.getParameter("fecha"));
	eco.setHora(request.getParameter("hora"));
	cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	eco.setFechaRegistro(cDateTime);
	eco.setHoraRegistro(cDateTime.substring(11));
	eco.setEvaluacionDerecha(request.getParameter("derecha"));
	eco.setEvaluacionIzquierda(request.getParameter("izquierda"));
	eco.setFechaCreacion(cDateTime);
	eco.setFechaModificacion(cDateTime);
	eco.setUsuarioCreacion((String) session.getAttribute("_userName"));
	eco.setUsuarioModificacion((String) session.getAttribute("_userName"));
	eco.setTipo(request.getParameter("fg"));

    for (int i = 0; i < totalH; i++) {
        if(request.getParameter("escala"+i) != null){
            
            String tipoEscala = request.getParameter("tipo_escala"+i);
            
            DetalleResultadoEscala dre = new DetalleResultadoEscala();
            
            dre.setTipoEscala(request.getParameter("tipo_escala"+i));
            dre.setDetalle(request.getParameter("escala"+i));
            
            dre.setAplicar("S");
            dre.setValor(request.getParameter("valor"+i));
            dre.setObservacion(request.getParameter("observacion"+i));
            dre.setCodPaciente(request.getParameter("codPac"));
            dre.setFecNacimiento(request.getParameter("dob"));
            dre.setSecuencia(request.getParameter("noAdmision"));
            dre.setPacId(request.getParameter("pacId"));
            dre.setFechaEscala(request.getParameter("fecha"));
            dre.setHoraEscala(request.getParameter("hora"));
            eco.addDetalleResultadoEscala(dre);
        }
    }
    eco.setTotal(request.getParameter("total2"));
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    ECMgr.add(eco);
    ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (ECMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_escala_glasgow.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_escala_glasgow.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%	} %>
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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&fg=<%=fg%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval=<%=fecha_eval%>&hora_eval=<%=hora_eval%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
