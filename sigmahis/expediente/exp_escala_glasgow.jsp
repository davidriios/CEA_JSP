<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.EscalaComa"%>
<%@ page import="issi.expediente.DetalleResultadoEscala"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora , total as total from tbl_sal_escala_coma  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and tipo ='"+fg+"' order by fecha desc";
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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'ESCALA GLASGOW - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function verEscala(k,mode){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;var hora_e = eval('document.form0.hora_evaluacion'+k).value ;window.location = '../expediente/exp_escala_glasgow.jsp?&modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e+'&hora_eval='+hora_e;}
function doAction(){setHeight();checkViewMode();}
function setHeight(){newHeight();}
function setEscalaValor(k,codigo,valor){var vIni = eval('document.form0.valIni').value;if(vIni == "1"){eval('document.form0.total2').value = "0";eval('document.form0.valIni').value = "0";distValor(k);}eval('document.form0.opcion').value = "1";eval('document.form0.total2').value = parseInt(eval('document.form0.total2').value )-parseInt(eval('document.form0.valor'+k).value );document.getElementById("valor"+k).value = valor;document.getElementById("codDetalle"+k).value = codigo;eval('document.form0.total2').value = parseInt(eval('document.form0.total2').value )+parseInt(valor);}
function distValor(j){var size1 = parseInt(document.getElementById("size").value);for (i=1;i<=size1;i++){if(i!=j)document.getElementById("escala"+i).checked = false;}eval('document.form0.opcion').value = "1";}
function sumaEscala(){var total = 0;for (i=1;i<=parseInt(document.getElementById("size").value);i++){total = total + parseInt(document.getElementById("valorL"+i).value);}if(!<%=viewMode%>)document.getElementById("total2").value = total;eval('document.form0.valIni').value = "1";}
function setAlert(){alert('No se ha realizado la evaluación');}
function printEscala(){var fecha = document.form0.fecha.value;var hora = document.form0.hora.value;abrir_ventana1('../expediente/print_escala_glasgow.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&fechaEscala='+fecha+'&horaEscala='+hora);}
function eTrauma(){if (window.estadoAtencion != "F"){parent.setPatientInfo('form0','iDetalle');var fecha = document.form0.fecha.value;var hora = document.form0.hora.value;var dob = document.form0.dob.value;var codPac = document.form0.codPac.value;var flag = false;var mode = '<%=modeSec%>';if (mode != 'view') flag = false;var viewMode = '';var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_escala_coma','fecha = to_date(\''+fecha+'\',\'dd/mm/yyyy\') and hora = to_date(\'01/\'||to_char(fecha,\'mm/yyyy\')||\' '+hora+'\',\'dd/mm/yyyy hh12:mi:ss am\') and pac_id = <%=pacId%> and secuencia = <%=noAdmision%>',''));var r1=splitRowsCols(getDBData('<%=request.getContextPath()%>','to_char(fecha_trauma,\'dd/mm/yyyy\') FT, to_char(hora,\'hh12:mi:ss am\') HT','tbl_sal_escala_coma','fecha_trauma = to_date(\''+fecha+'\',\'dd/mm/yyyy\') and hora_trauma = to_date(\'01/\'||to_char(hora_registro,\'mm/yyyy\')||\' '+hora+'\',\'dd/mm/yyyy hh12:mi:ss am\') and pac_id = <%=pacId%> and secuencia = <%=noAdmision%>','group by to_char(fecha_trauma,\'dd/mm/yyyy\'), to_char(hora,\'hh12:mi:ss am\')'));var fechaEval = "";var horaEval  = "";if ( r > 0 ){if (r1 != null ){fechaEval = r1[0][0];horaEval  = r1[0][1];viewMode = 'view';alert("Esta escala ya ha sido evaluada, la pantalla se abrirá en modo de lectura!");flag = true;}else{viewMode = "";flag = true;}}else if ( mode != 'view' ){alert("Usted tiene que crear o seleccionar la escala de Glasgow antes de evaluarla!");flag = false;}else{alert("Usted tiene que crear o seleccionar la escala de Glasgow antes de evaluarla!");flag = false;}if(flag) abrir_ventana1('../expediente/exp_evaluacion_trauma.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&fp=<%=fp%>&fechaEscala='+fecha+'&horaEscala='+hora+'&dob='+dob+'&codPac='+codPac+'&mode=<%=mode%>&modeSec='+viewMode+'&fechaEval='+fechaEval+'&horaEval='+horaEval);}}
function add(){	window.location = "../expediente/exp_escala_glasgow.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&modeSec=add&fg=<%=fg%>";}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
			<tr>
					<td  colspan="6" onClick="javascript:setHeight()" style="text-decoration:none; cursor:pointer">
					<div id="listado" width="100%" class="exp h100">
					<div id="detListado" width="98%" class="child">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td colspan="4">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones Escala Glasgow del coma</cellbytelabel></td>
						</tr>
						<tr class="TextHeader" align="center">
								<td width="20%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
								<td width="20%"><cellbytelabel id="3">Hora</cellbytelabel></td>
								<td width="20%"><cellbytelabel id="4">Puntos</cellbytelabel></td>
								<td width="40%"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
							</tr>

							<%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
							<%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
							<%=fb.hidden("hora_evaluacion0",cDateTime.substring(11))%>
							<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')" style="cursor:pointer " onClick="javascript:verEscala(0,'add')" >
									<td><%=cDateTime.substring(0,10)%></td>
									<td><%=cDateTime.substring(11)%></td>
									<td>----</td>
									<td><cellbytelabel id="6">Evaluaci&oacute;n actual</cellbytelabel></td>
							</tr>
<%}
al2 = CmnMgr.reverseRecords(HashEsc);
for (int i=1; i<=HashEsc.size(); i++)
{
	key = al2.get(i-1).toString();
	cdo = (CommonDataObject) HashEsc.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("hora_evaluacion"+i,cdo.getColValue("hora"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verEscala(<%=i%>,'view')">
				<td><%=cdo.getColValue("fecha")%></td>
				<td><%=cdo.getColValue("hora")%></td>
				<td><%=cdo.getColValue("total")%></td>
				<td><%=cdo.getColValue("observacion")%></td>
		</tr>
<%
}
%>
						</table>
					</div>
					</div>	
					</td>
				</tr>
			<tr class="TextRow02">
				<td colspan="3">
				<table border="0" cellpadding="0" cellspacing="0" class="TextRow02" width="100%">
					<tr class="TextRow01">
					<td colspan="4" align="right">
                   <% if (!mode.trim().equals("view")){ %>
                       <a href="javascript:add()" class="Link00">[ <cellbytelabel id="7">Agregar</cellbytelabel> ]</a>
                    <%}%>
                    <a href="javascript:eTrauma()" class="Link00">[ <cellbytelabel id="8">Eval. Trauma</cellbytelabel> ]</a> <a href="javascript:printEscala()" class="Link00">[ <cellbytelabel id="9">Imprimir</cellbytelabel> ]</a>
                    </td>
					</tr> 
					<tr>
						<td width="25%"><cellbytelabel id="2">Fecha</cellbytelabel>:&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=escComa.getFecha()%>" />
                            <jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>" />
							</jsp:include></td>
						<td width="25%"><cellbytelabel id="3">Hora</cellbytelabel>:&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="format" value="hh12:mi:ss am"/>
							<jsp:param name="nameOfTBox1" value="hora" />
							<jsp:param name="valueOfTBox1" value="<%=escComa.getHora()%>" />
                            <jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>" />
							</jsp:include></td>
						<td width="15%" nowrap><cellbytelabel id="10">Evaluaci&oacute;n Pupilar</cellbytelabel></td>
						<td nowrap>
						<table border="0" cellpadding="0" cellspacing="0" class="TextRow02">
							<tr align="center">
								<td>&nbsp;</td>
								<td>1</td>
								<td>2</td>
								<td>3</td>
								<td>4</td>
								<td>5</td>
								<td>6</td>
								<td>7</td>
								<td>8</td>
								<td>9</td>
							</tr>
							<tr align="center" valign="middle">
								<td>&nbsp;</td>
								<td><img height="12" width="12" class="ImageBorder" src="../images/blackball.gif"></td>
								<td><img height="15" width="15" src="../images/blackball.gif"></td>
								<td><img height="18" width="18" src="../images/blackball.gif"></td>
								<td><img height="21" width="21" src="../images/blackball.gif"></td>
								<td><img height="24" width="24" src="../images/blackball.gif"></td>
								<td><img height="27" width="27" src="../images/blackball.gif"></td>
								<td><img height="30" width="30" src="../images/blackball.gif"></td>
								<td><img height="33" width="33" src="../images/blackball.gif"></td>
								<td><img height="36" width="36" src="../images/blackball.gif"></td>
							</tr>
							<tr align="center">
								<td><cellbytelabel id="11">Der</cellbytelabel>.:</td>
								<td><%=fb.radio("derecha","1",escComa.getEvaluacionDerecha().equals("1"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","2",escComa.getEvaluacionDerecha().equals("2"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","3",escComa.getEvaluacionDerecha().equals("3"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","4",escComa.getEvaluacionDerecha().equals("4"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","5",escComa.getEvaluacionDerecha().equals("5"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","6",escComa.getEvaluacionDerecha().equals("6"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","7",escComa.getEvaluacionDerecha().equals("7"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","8",escComa.getEvaluacionDerecha().equals("8"),viewMode,false)%></td>
								<td><%=fb.radio("derecha","9",escComa.getEvaluacionDerecha().equals("9"),viewMode,false)%></td>
							</tr>
							<tr align="center">
								<td><cellbytelabel id="12">Izq</cellbytelabel>.:</td>
								<td><%=fb.radio("izquierda","1",escComa.getEvaluacionIzquierda().equals("1"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","2",escComa.getEvaluacionIzquierda().equals("2"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","3",escComa.getEvaluacionIzquierda().equals("3"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","4",escComa.getEvaluacionIzquierda().equals("4"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","5",escComa.getEvaluacionIzquierda().equals("5"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","6",escComa.getEvaluacionIzquierda().equals("6"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","7",escComa.getEvaluacionIzquierda().equals("7"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","8",escComa.getEvaluacionIzquierda().equals("8"),viewMode,false)%></td>
								<td><%=fb.radio("izquierda","9",escComa.getEvaluacionIzquierda().equals("9"),viewMode,false)%></td>
							</tr>
						</table></td>
					</tr>
				</table></td>
				</tr>
			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
				</tr>
			<tr class="TextHeader" align="center">
				<td width="30%"><cellbytelabel id="13">Funciones Neurol&oacute;gicas</cellbytelabel></td>
				<td width="35%"><cellbytelabel id="14">Escala</cellbytelabel></td>
				<td width="35%"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
			</tr>
<%
		int lc=0  ;
		String codE = "", observ = "";
		String codAnt = "";//al = CmnMgr.reverseRecords(HashDet);
		String detalleCod = "";
		boolean codDetSig = false;
		for (int i = 0; i <al.size(); i++)
		{
			key = al.get(i).toString();
			cdo = (CommonDataObject) al.get(i);
			codE = cdo.getColValue("codigo");

			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
if(cdo.getColValue("cod_escala").equals("0"))
{
			lc++;
			eTotal += Integer.parseInt(cdo.getColValue("valor"));
			detalleCod = cdo.getColValue("detalle");

			observ = cdo.getColValue("observacion");
			if(cdo.getColValue("detalle").equals("0") && !viewMode )
			{
						codDetSig = true;
			}
%>
			<%=fb.hidden("tipo_escala"+lc,cdo.getColValue("codigo"))%>
			<%=fb.hidden("codDetalle"+lc,"0")%>
			<%=fb.hidden("valor"+lc,"0")%>
			<%=fb.hidden("opcion","0")%>

			<tr class="<%=color%>">
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="<%=color%>">
<%}
else if(!cdo.getColValue("cod_escala").equals("0"))
{
%>
					<%=fb.hidden("valorL"+lc,cdo.getColValue("escala"))%>
					<%=fb.hidden("codDetalle1"+lc,cdo.getColValue("cod_escala"))%>
					<tr>
							<td width="5%" valign="top" ><!---codDetSig ||--para que el primer check este seleccionado-->
							<%=fb.radio("escala"+lc, cdo.getColValue("cod_escala"),(detalleCod.equals(cdo.getColValue("cod_escala"))|| codDetSig ),viewMode, false , "", "", "onClick=\"javascript:setEscalaValor('"+lc+"','"+cdo.getColValue("cod_escala")+"','"+cdo.getColValue("escala")+"')  \" ")%>						</td>
										<td valign="top" width="90%"><%=cdo.getColValue("descripcion")%></td>
										<td width="5%" align="right" valign="middle">[<%=cdo.getColValue("escala")%>]</td>
									</tr>
								<%// }//if
								codDetSig=false;
						if(i<al.size()-1)
						{
							 cdo = (CommonDataObject) al.get(i+1);
							 codAnt = cdo.getColValue("codigo");
						}
						else
						{%>
						</table>
							</td>
							<td><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,30,3,2000,null,"",null)%></td>
								</tr>
							<%
							detalleCod="";
						}
						if(!codAnt.equals(codE))
						{
					%></table>
							</td>
							<td><%=fb.textarea("observacion"+lc,observ,false,false,viewMode,50,3,2000,null,"width='100%'",null)%></td>
								</tr>
							<%	detalleCod="";}
							}//else%>
					
							
<%
}
%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right">Total:<%=fb.intBox("total2",""+eTotal+"",false,false,true,2)%></td>
				<td>&nbsp;</td>
				</tr>
<%=fb.hidden("size",""+lc)%>

			<tr class="TextRow02" >
				<td colspan="3" align="right">
				<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="16">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="17">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</tr>
			<%=fb.formEnd(true)%>
	<!---	---> <script type="text/javascript">sumaEscala();</script>
			</table>
		</td>
	</tr>
</table>
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

for (int i=1; i<=size; i++)
{


			if(request.getParameter("escala"+i) != null){
			DetalleResultadoEscala dre = new DetalleResultadoEscala();

			dre.setTipoEscala(request.getParameter("tipo_escala"+i));//codigo

			if(request.getParameter("valIni").equals("1"))
			{
					dre.setDetalle(request.getParameter("codDetalle1"+i));//codDetalle
					dre.setValor(request.getParameter("valorL"+i));//
					tpuntos += Integer.parseInt(request.getParameter("valorL"+i));
			}
			else if(request.getParameter("escala"+i) != null)
			{
					dre.setDetalle(request.getParameter("codDetalle"+i));//codDetalle
					dre.setValor(request.getParameter("valor"+i));//
					tpuntos = Integer.parseInt(request.getParameter("total2"));
			}
			dre.setAplicar("S");//
			dre.setObservacion(request.getParameter("observacion"+i));	//obsservacion
			dre.setCodPaciente(request.getParameter("codPac"));
			dre.setFecNacimiento(request.getParameter("dob"));
			dre.setSecuencia(request.getParameter("noAdmision"));
			dre.setPacId(request.getParameter("pacId"));
			dre.setFechaEscala(request.getParameter("fecha"));
			dre.setHoraEscala(request.getParameter("hora"));
			eco.addDetalleResultadoEscala(dre);
			}
}
						eco.setTotal(""+tpuntos);
						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							ECMgr.add(eco);
						ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript">
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

