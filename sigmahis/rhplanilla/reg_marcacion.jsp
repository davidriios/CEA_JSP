<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
sct0095_correc: para editar y consultar
sct0095_ces: solo para consultar
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

SQLMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
CommonDataObject cdo;
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String iDate = request.getParameter("iDate");
String fDate = request.getParameter("fDate");
String empId = request.getParameter("empId");
String fg = request.getParameter("fg");

if (grupo == null) grupo = "";
if (area == null) area = "";
if (iDate == null) iDate = "";
if (fDate == null) fDate = "";
if (empId == null) empId = "";
if (fg == null) fg = "";

if (grupo.trim().equals("")/* || area.trim().equals("")*/) throw new Exception("Grupo o Sección inválida!");
if (iDate.trim().equals("") || fDate.trim().equals("") || empId.trim().equals("")) throw new Exception("Empleado o Periódo de Planilla inválido!");
if (iDate.equals(fDate)) {
	if (!fg.equalsIgnoreCase("tard")) {
		iDate = "to_date('01"+iDate.substring(iDate.indexOf("/"));
		fDate = "last_day("+iDate+")";
	}
	/*if (Integer.parseInt(iDate.substring(iDate.indexOf("'") + 1,iDate.indexOf("/"))) <= 15) {
		iDate = "to_date('01"+iDate.substring(iDate.indexOf("/"));
		fDate = "to_date('15"+fDate.substring(fDate.indexOf("/"));
	} else {
		iDate = "to_date('16"+iDate.substring(iDate.indexOf("/"));
		fDate = "last_day("+iDate+")";
	}*/
}

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")) {
	sbSql.append("select provincia, sigla, tomo, asiento, num_empleado, primer_nombre||' '||primer_apellido||' '||case when sexo = 'F' and apellido_casada is not null then apellido_casada else segundo_apellido end as nombre from tbl_pla_empleado where emp_id = ");
	sbSql.append(empId);
	cdo = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select x.anio, lpad(x.mes,2,'0') as mes, lpad(x.dia,2,'0') as dia, nvl(to_char(x.entrada,'hh12:mi am'),' ') as entrada, nvl(to_char(x.salida_com,'hh12:mi am'),' ') as salida_com, nvl(to_char(x.entrada_com,'hh12:mi am'),' ') as entrada_com, nvl(to_char(x.salida,'hh12:mi am'),' ') as salida, nvl(x.programa,' ') as programa, nvl(x.turno,' ') as turno, substr(to_char(to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy'),'DAY','NLS_DATE_LANGUAGE=SPANISH'),1,3) as dia_semana, decode(x.turno,null,'CODIGO NO DEFINIDO',case when x.programa = 'S' then (select descripcion from tbl_pla_ct_turno where codigo = x.turno and compania = x.compania) else (select 'DE '||to_char(hora_entrada,'HH12:MI AM')||decode(hora_salida_almuerzo,null,'','  A  '||to_char(hora_salida_almuerzo,'HH12:MI AM'))||decode(hora_entrada_almuerzo,null,'','  Y  DE  '||to_char(hora_entrada_almuerzo,'HH12:MI AM'))||'  A  '||to_char(hora_salida,'HH12:MI AM') from tbl_pla_horario_trab where codigo = x.turno and compania = x.compania) end) as turno_dsp from tbl_pla_marcacion x where x.emp_id = ");
	sbSql.append(empId);
	sbSql.append(" and to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy') between ");
	sbSql.append(iDate);
	sbSql.append(" and ");
	sbSql.append(fDate);
	sbSql.append(" order by x.anio desc, x.mes desc, x.dia");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Marcación - '+document.title;
function doAction(){}
function viewDial(fecha){showPopWin('../rhplanilla/marcacion.jsp?mode=<%=mode%>&empId=<%=empId%>&fecha='+fecha,winWidth*.65,_contentHeight*.85,null,null,'');}
function removeDial(k){var dd=eval('document.form0.dia'+k).value;var mm=eval('document.form0.mes'+k).value;var yyyy=eval('document.form0.anio'+k).value;if(parseInt(getDBData("<%=request.getContextPath()%>","count(*)","tbl_pla_marcacion","emp_id = <%=empId%> and to_date(dia||'/'||mes||'/'||anio) = to_date('"+dd+"/"+mm+"/"+yyyy+"','dd/mm/yyyy')",""),10)<=1){alert('ATENCION: Para poder eliminar un registro es necesario que para ese día el empleado tenga más de un registro de marcación, si este es el único registro de marcación NO PODRÁ SER ELIMINADO!!!');return false;}else{if(confirm('Una vez eliminado y guardado, el registro no podrá ser recuperado. ¿Está seguro de ejecutar esta acción?')){if(document.getElementById('marc'+k))document.getElementById('marc'+k).style.display='none';if(eval('document.form0.action'+k))eval('document.form0.action'+k).value='D';}}return true;}
var tTime=null;
var tDate=null;
function setTmpObj(obj,k){
  //tTime=obj;
  //tDate=eval('document.form0.dia'+k).value+'/'+eval('document.form0.mes'+k).value+'/'+eval('document.form0.anio'+k).value;
  $("#cIndex").val(k);
  $("#cTimeObjName").val(obj.name);
}

function copiar(){
   var i = $("#cIndex").val();
   var cTimeObjName = $("#cTimeObjName").val();
   var copyingDate = $("#dia"+i).val()+"/"+$("#dia"+i).val()+"/"+$("#anio"+i).val();
   var copyingTime = $("#"+cTimeObjName).val();

   if( !copyingTime ){
     alert('La marcación a copiar no es válida!');return false;
   }else{
     document.form0.cpDate.value = copyingDate;
     document.form0.cpTime.value = copyingTime;
     $("#copyingDate").val(copyingDate);
     $("#copyingTime").val(copyingTime);
     tDate = copyingDate;
     displayElementValue('lblCP',copyingDate+' '+copyingTime);
   }
  return true;
}

function copiar_old(){if(tTime==null){alert('Por favor haga clic en la marcación antes de copiar!');return false;}else if(tTime.value.trim()==''){alert('La marcación a copiar no es válida!');return false;}else{document.form0.cpDate.value=tDate;document.form0.cpTime.value=tTime.value;displayElementValue('lblCP',tDate+' '+tTime.value);}return true;}

function pegar(){ 
    
    var cTimeObjName = $("#cTimeObjName").val();
    
	if(!$("#copyingTime").val()){alert('Por favor haga clic en la marcación y copie antes de pegar!');return false;}
	else if(document.form0.cpTime.value.trim()==''){alert('No es posible pegar marcación ya que no hay marcación copiada!');return false;}
	else{
		var df="'hh12:mi am'";
		var cpDate=document.form0.cpDate.value;
		var cpTime=document.form0.cpTime.value;
		var idx=$("#cIndex").val();
		var colType=null;
		if(cTimeObjName.indexOf('_com')==-1){
			if(cTimeObjName.indexOf('entrada')!=-1){colType=1;}
			else{colType=4;}
		}else{
			if(cTimeObjName.indexOf('salida')!=-1){colType=2;}
			else{colType=3;}
		}

		var fecha=eval('document.form0.dia'+idx).value+'/'+eval('document.form0.mes'+idx).value+'/'+eval('document.form0.anio'+idx).value;
		var entrada=eval('document.form0.entrada'+idx).value;
		var salidaCom=eval('document.form0.salida_com'+idx).value;
		var entradaCom=eval('document.form0.entrada_com'+idx).value;
		var salida=eval('document.form0.salida'+idx).value;
		if(colType==1){
			var fCheck="case when to_date('"+cpDate+"','dd/mm/yyyy') <> to_date('"+tDate+"','dd/mm/yyyy') then 1 else 0 end";
			if(salidaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salidaCom+"',"+df+") then 1 else 0 end";
			if(entradaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+entradaCom+"',"+df+") then 1 else 0 end";
			if(salida=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salida+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de otro día como ENTRADA para este registro');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA mayor a la marcación de SALIDA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA mayor a la marcación de ENTRADA DE COMIDA');return false;}
				else if(c[3]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA mayor a la marcación de SALIDA');return false;}
			}
		}else if(colType==2){
			var fCheck="";
			if(entrada=='')fCheck+="0";
			else fCheck+="case when to_date('"+cpTime+"',"+df+") < to_date('"+entrada+"',"+df+") then 1 else 0 end";
			if(entradaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+entradaCom+"',"+df+") then 1 else 0 end";
			if(salida=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salida+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA DE COMIDA menor a la marcación de ENTRADA');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA DE COMIDA mayor a la marcación de ENTRADA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA DE COMIDA mayor a la marcación de SALIDA');return false;}
			}
		}else if(colType==3){
			var fCheck="";
			if(entrada=='')fCheck+="0";
			else fCheck+="case when to_date('"+cpTime+"',"+df+") < to_date('"+entrada+"',"+df+") then 1 else 0 end";
			if(salidaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") < to_date('"+salidaCom+"',"+df+") then 1 else 0 end";
			if(salida=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salida+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA DE COMIDA menor a la marcación de ENTRADA');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA DE COMIDA menor a la marcación de SALIDA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA DE COMIDA mayor a la marcación de SALIDA');return false;}
			}
		}else if(colType==4){
			var fCheck="";
			if(entrada=='')fCheck+="0";

			else fCheck+="case when to_date('"+cpDate+" "+cpTime+"','dd/mm/yyyy hh12:mi am') < to_date('"+fecha+" "+entrada+"','dd/mm/yyyy hh12:mi am') then 1 when round((to_date('"+cpDate+" "+cpTime+"','dd/mm/yyyy hh12:mi am') - to_date('"+fecha+" "+entrada+"','dd/mm/yyyy hh12:mi am')) * 24,2) >= 24 then 2 else 0 end";
			if(salidaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") < to_date('"+salidaCom+"',"+df+") then 1 else 0 end";
			if(entradaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") < to_date('"+entradaCom+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA menor a la marcación de ENTRADA');return false;}
				else if(c[0]==2){alert('ATENCION: Por favor verifique lo que intenta pegar pues la diferencia de ENTRADA - SALIDA es de 24 horas o más!!!');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA menor a la marcación de SALIDA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA menor a la marcación de ENTRADA DE COMIDA');return false;}
			}
		}
        
        if (cpDate){
           var cpDArr = cpDate.split("/");
           $("#dia"+idx).val(cpDArr[0]);
           $("#mes"+idx).val(cpDArr[1]);
           $("#anio"+idx).val(cpDArr[2]);
           $("#"+cTimeObjName).val(cpTime);
        }else{
         alert("No está copiando la fecha!");
         return false;
        }
	}
}

function pegar_old(){ 
    alert(document.form0.cpDate.value+" "+document.form0.cpTime.value);
	if(tTime==null){alert('Por favor haga clic en la marcación y copie antes de pegar!');return false;}
	else if(document.form0.cpTime.value.trim()==''){alert('No es posible pegar marcación ya que no hay marcación copiada!');return false;}
	else{
		var df="'hh12:mi am'";
		var cpDate=document.form0.cpDate.value;
		var cpTime=document.form0.cpTime.value;
		var idx=null;
		var colType=null;
		if(tTime.name.indexOf('_com')==-1){
			if(tTime.name.indexOf('entrada')!=-1){idx=tTime.name.replace('entrada','');colType=1;}
			else{idx=tTime.name.replace('salida','');colType=4;}
		}else{
			if(tTime.name.indexOf('salida')!=-1){idx=tTime.name.replace('salida_com','');colType=2;}
			else{idx=tTime.name.replace('entrada_com','');colType=3;}
		}
		var fecha=eval('document.form0.dia'+idx).value+'/'+eval('document.form0.mes'+idx).value+'/'+eval('document.form0.anio'+idx).value;
		var entrada=eval('document.form0.entrada'+idx).value;
		var salidaCom=eval('document.form0.salida_com'+idx).value;
		var entradaCom=eval('document.form0.entrada_com'+idx).value;
		var salida=eval('document.form0.salida'+idx).value;
		if(colType==1){
			var fCheck="case when to_date('"+cpDate+"','dd/mm/yyyy') <> to_date('"+tDate+"','dd/mm/yyyy') then 1 else 0 end";
			if(salidaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salidaCom+"',"+df+") then 1 else 0 end";
			if(entradaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+entradaCom+"',"+df+") then 1 else 0 end";
			if(salida=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salida+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de otro día como ENTRADA para este registro');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA mayor a la marcación de SALIDA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA mayor a la marcación de ENTRADA DE COMIDA');return false;}
				else if(c[3]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA mayor a la marcación de SALIDA');return false;}
			}
		}else if(colType==2){
			var fCheck="";
			if(entrada=='')fCheck+="0";
			else fCheck+="case when to_date('"+cpTime+"',"+df+") < to_date('"+entrada+"',"+df+") then 1 else 0 end";
			if(entradaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+entradaCom+"',"+df+") then 1 else 0 end";
			if(salida=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salida+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA DE COMIDA menor a la marcación de ENTRADA');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA DE COMIDA mayor a la marcación de ENTRADA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA DE COMIDA mayor a la marcación de SALIDA');return false;}
			}
		}else if(colType==3){
			var fCheck="";
			if(entrada=='')fCheck+="0";
			else fCheck+="case when to_date('"+cpTime+"',"+df+") < to_date('"+entrada+"',"+df+") then 1 else 0 end";
			if(salidaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") < to_date('"+salidaCom+"',"+df+") then 1 else 0 end";
			if(salida=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") > to_date('"+salida+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA DE COMIDA menor a la marcación de ENTRADA');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA DE COMIDA menor a la marcación de SALIDA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de ENTRADA DE COMIDA mayor a la marcación de SALIDA');return false;}
			}
		}else if(colType==4){
			var fCheck="";
			if(entrada=='')fCheck+="0";
			//else fCheck+="case when to_date('"+cpTime+"',"+df+") < to_date('"+entrada+"',"+df+") then 1 when round((to_date('"+cpDate+" "+cpTime+"','dd/mm/yyyy hh12:mi am') - to_date('"+fecha+" "+entrada+"','dd/mm/yyyy hh12:mi am')) * 24,2) >= 24 then 2 else 0 end";
			else fCheck+="case when to_date('"+cpDate+" "+cpTime+"','dd/mm/yyyy hh12:mi am') < to_date('"+fecha+" "+entrada+"','dd/mm/yyyy hh12:mi am') then 1 when round((to_date('"+cpDate+" "+cpTime+"','dd/mm/yyyy hh12:mi am') - to_date('"+fecha+" "+entrada+"','dd/mm/yyyy hh12:mi am')) * 24,2) >= 24 then 2 else 0 end";
			if(salidaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") < to_date('"+salidaCom+"',"+df+") then 1 else 0 end";
			if(entradaCom=='')fCheck+=", 0";
			else fCheck+=", case when to_date('"+cpTime+"',"+df+") < to_date('"+entradaCom+"',"+df+") then 1 else 0 end";
			var c=splitCols(getDBData('<%=request.getContextPath()%>',fCheck,'dual','',''));
			if(c!=null){
				if(c[0]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA menor a la marcación de ENTRADA');return false;}
				else if(c[0]==2){alert('ATENCION: Por favor verifique lo que intenta pegar pues la diferencia de ENTRADA - SALIDA es de 24 horas o más!!!');return false;}
				else if(c[1]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA menor a la marcación de SALIDA DE COMIDA');return false;}
				else if(c[2]==1){alert('ATENCION: No está permitido insertar una marcación de SALIDA menor a la marcación de ENTRADA DE COMIDA');return false;}
			}
		}
		tTime.value=cpTime;
	}
	return true;
}
function setBlank(obj){if(confirm('¿Está seguro que desea eliminar esta marcación?'))obj.value='';return true;}
function printReport(){abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_asistencia.rptdesign&pGrupo=<%=grupo%>&pArea=<%=area%>&pInicial=<%=issi.admin.IBIZEscapeChars.forURL(iDate)%>&pFinal=<%=issi.admin.IBIZEscapeChars.forURL(fDate)%>&pEmpId=<%=empId%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MARCACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("iDate",iDate)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cpTime","")%>
<%=fb.hidden("cpDate","")%>
<%=fb.hidden("dialTime","")%>
<%=fb.hidden("dialDate","")%>
<%=fb.hidden("cIndex","")%>
<%=fb.hidden("cTimeObjName","")%>
<%=fb.hidden("fromPopupMarcacion","")%>
<%=fb.hidden("copyingDate","")%>
<%=fb.hidden("copyingTime","")%>
		<tr class="TextFilter">
			<td width="6%" align="right">Empl. Id</td>
			<td width="10%"><%=empId%></td>
			<td width="6%" align="right"># Empl.</td>
			<td width="10%"><%=cdo.getColValue("num_empleado")%></td>
			<td width="8%" align="right">Nombre</td>
			<td width="40%"><%=cdo.getColValue("nombre")%></td>
			<td width="8%" align="right">C&eacute;dula</td>
			<td width="12%"><%=cdo.getColValue("provincia")%>-<%=cdo.getColValue("sigla")%>-<%=cdo.getColValue("tomo")%>-<%=cdo.getColValue("asiento")%></td>
		</tr>
		<tr>
			<td colspan="8">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td rowspan="2" colspan="2"><% if (!viewMode) { %><img src="../images/copy.png" border="0" width="<%=iconWidth%>" height="<%=iconHeight%>" alt="Copiar" onClick="javascript:copiar()" style="cursor:pointer"><img src="../images/paste.png" border="0" width="<%=iconWidth%>" height="<%=iconHeight%>" alt="Pegar" onClick="javascript:pegar()" style="cursor:pointer"><br><label id="lblCP" class="RedText Text10"></label><% } %></td>
					<td width="3%" rowspan="2">D&iacute;a</td>
					<td width="3%" rowspan="2">Mes</td>
					<td width="4%" rowspan="2">A&ntilde;o</td>
					<td width="7%" rowspan="2">Entrada</td>
					<td colspan="2">Comida</td>
					<td width="7%" rowspan="2">Salida</td>
					<td width="2%" rowspan="2">&nbsp;</td>
					<td width="6%" rowspan="2">Prog. Turno</td>
					<td width="40%" rowspan="2">Horario Programado o Asignado</td>
					<td width="3%" rowspan="2">&nbsp;</td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="7%">Salida</td>
					<td width="7%">Entrada</td>
				</tr>
<%
StringBuffer sbEvt = new StringBuffer();
if (!viewMode) {
	sbEvt.append(" onDblClick=\"javascript:setBlank(this);\"");
	sbEvt.append(" onClick=\"javascript:setTmpObj(this,IDX);\"");
}
%>
<% for (int i=0; i<al.size(); i++) { cdo = (CommonDataObject) al.get(i); String evt = sbEvt.toString(); evt = evt.replaceAll("IDX",""+i); %>
				<%//=fb.hidden("dia"+i,cdo.getColValue("dia"))%>
				<%//=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
				<%//=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
				<%=fb.hidden("entrada_o"+i,cdo.getColValue("entrada"))%>
				<%=fb.hidden("salida_com_o"+i,cdo.getColValue("salida_com"))%>
				<%=fb.hidden("entrada_com_o"+i,cdo.getColValue("entrada_com"))%>
				<%=fb.hidden("salida_o"+i,cdo.getColValue("salida"))%>
				<%=fb.hidden("programa"+i,cdo.getColValue("programa"))%>
				<%=fb.hidden("turno"+i,cdo.getColValue("turno"))%>
				<%=fb.hidden("action"+i,"U")%>
				<tr class="TextRow01" align="center" id="marc<%=i%>">
					<td width="3%"><a href="javascript:viewDial('<%=cdo.getColValue("dia")%>/<%=cdo.getColValue("mes")%>/<%=cdo.getColValue("anio")%>')"><img src="../images/clock-link.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>"></a></td>
					<td width="8%"><%=cdo.getColValue("dia_semana")%></td>
					<td>
                    <%=fb.textBox("dia"+i,cdo.getColValue("dia"),false,false,false,1,"Text10",null,null)%>
                    <%//=cdo.getColValue("dia")%>
                    </td>
					<td>
                    <%=fb.textBox("mes"+i,cdo.getColValue("mes"),false,false,true,1,"Text10",null,null)%>
                    <%//=cdo.getColValue("mes")%></td>
					<td>
                    <%=fb.textBox("anio"+i,cdo.getColValue("anio"),false,false,true,2,"Text10",null,null)%>
                    <%//=cdo.getColValue("anio")%></td>
					<td><%=fb.textBox("entrada"+i,cdo.getColValue("entrada"),false,false,true,9,"Text10",null,evt)%></td>
					<td><%=fb.textBox("salida_com"+i,cdo.getColValue("salida_com"),false,false,true,9,"Text10",null,evt)%></td>
					<td><%=fb.textBox("entrada_com"+i,cdo.getColValue("entrada_com"),false,false,true,9,"Text10",null,evt)%></td>
					<td><%=fb.textBox("salida"+i,cdo.getColValue("salida"),false,false,true,9,"Text10",null,evt)%></td>
					<td><%=fb.checkbox("programaDsp"+i,"S",(cdo.getColValue("programa").equalsIgnoreCase("S")),true,null,null,null)%></td>
					<td><%=cdo.getColValue("turno")%></td>
					<td align="left"><%=cdo.getColValue("turno_dsp")%></td>
					<td><%=fb.button("rem"+i,"X",true,viewMode,"Text10",null,"onClick=\"javascript:removeDial("+i+")\"")%></td>
				</tr>
<% } %>
				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<a href="javascript:printReport()"><img src="../images/printer.gif" border="0" width="20" height="20"></a>
				Opciones de Guardar:
				<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,viewMode,"","","onClick=\"javascript:setBAction(this.form.name,this.value);\"")%>
				<%=fb.button("cancel","Cancelar",false,false,"","","onClick=\"javascript:closeWin()\"")%>
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
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++) {
		cdo = new CommonDataObject();

		StringBuffer sbFecha = new StringBuffer();
		sbFecha.append(request.getParameter("dia"+i));
		sbFecha.append("/");
		sbFecha.append(request.getParameter("mes"+i));
		sbFecha.append("/");
		sbFecha.append(request.getParameter("anio"+i));

		cdo.setTableName("tbl_pla_marcacion");
		cdo.setAction(request.getParameter("action"+i));
		cdo.addColValue("entrada",(request.getParameter("entrada"+i).equals(""))?"":sbFecha+" "+request.getParameter("entrada"+i));
		cdo.addColValue("salida_com",(request.getParameter("salida_com"+i).equals(""))?"":sbFecha+" "+request.getParameter("salida_com"+i));
		cdo.addColValue("entrada_com",(request.getParameter("entrada_com"+i).equals(""))?"":sbFecha+" "+request.getParameter("entrada_com"+i));
		cdo.addColValue("salida",(request.getParameter("salida"+i).equals(""))?"":sbFecha+" "+request.getParameter("salida"+i));

		StringBuffer sbWhere = new StringBuffer();
		sbWhere.append("to_date(dia||'/'||mes||'/'||anio,'dd/mm/yyyy') = to_date('");
		sbWhere.append(sbFecha);
		sbWhere.append("','dd/mm/yyyy') and emp_id = " );
		sbWhere.append(empId);
		sbWhere.append(" and compania = ");
		sbWhere.append(session.getAttribute("_companyId"));
		
		
		if (request.getParameter("entrada_o"+i).trim().equals("")) {
			sbWhere.append(" and entrada is null");
		} else {
			sbWhere.append(" and entrada = to_date('");
			sbWhere.append(sbFecha);
			sbWhere.append(" ");
			sbWhere.append(request.getParameter("entrada_o"+i));
			sbWhere.append("','dd/mm/yyyy hh12:mi am')");
		}
		if (request.getParameter("salida_com_o"+i).trim().equals("")) {
			sbWhere.append(" and salida_com is null");
		} else {
			sbWhere.append(" and salida_com = to_date('");
			sbWhere.append(sbFecha);
			sbWhere.append(" ");
			sbWhere.append(request.getParameter("salida_com_o"+i));
			sbWhere.append("','dd/mm/yyyy hh12:mi am')");
		}
		if (request.getParameter("entrada_com_o"+i).trim().equals("")) {
			sbWhere.append(" and entrada_com is null");
		} else {
			sbWhere.append(" and entrada_com = to_date('");
			sbWhere.append(sbFecha);
			sbWhere.append(" ");
			sbWhere.append(request.getParameter("entrada_com_o"+i));
			sbWhere.append("','dd/mm/yyyy hh12:mi am')");
		}
		if (request.getParameter("salida_o"+i).trim().equals("")) {
			sbWhere.append(" and salida is null");
		} else {
			sbWhere.append(" and salida = to_date('");
			sbWhere.append(sbFecha);
			sbWhere.append(" ");
			sbWhere.append(request.getParameter("salida_o"+i));
			sbWhere.append("','dd/mm/yyyy hh12:mi am')");
		}
		cdo.setWhereClause(sbWhere.toString());
		al.add(cdo);
	}
	if (baction.equalsIgnoreCase("Guardar")) {
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.saveList(al,false);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% if (saveOption.equalsIgnoreCase("O")) { %>
setTimeout('openMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
 window.close();
<% } %>
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
function openMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&grupo=<%=grupo%>&area=<%=area%>&iDate=<%=issi.admin.IBIZEscapeChars.forURL(iDate)%>&fDate=<%=issi.admin.IBIZEscapeChars.forURL(fDate)%>&empId=<%=empId%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>