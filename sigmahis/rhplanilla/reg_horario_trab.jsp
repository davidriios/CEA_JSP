<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Horario"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="HorDet" scope="session" class="issi.rhplanilla.Horario" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="HorMgr" scope="page" class="issi.rhplanilla.HorarioMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
HorMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
boolean viewMode = false;

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if (mode != null && mode.equalsIgnoreCase("edit")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change==null){
		HorDet = new Horario();
		session.setAttribute("HorDet",HorDet);
	}
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else 
	{
		if (id == null) throw new Exception("Estado no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.compania, a.codigo, a.descripcion, to_char(a.hora_entrada,'HH12:MI AM') hora_entrada, to_char(a.hora_salida,'HH12:MI AM') hora_salida, a.dias, nvl(TO_CHAR(a.hora_salida_almuerzo,'HH12:MI AM'),'') hora_salida_almuerzo, nvl(to_char(a.hora_entrada_almuerzo,'HH12:MI AM'),'') hora_entrada_almuerzo, nvl(to_char(a.hora_gracia_entrada,'HH12:MI AM'),'') hora_gracia_entrada, nvl(a.comentario,'NA') comentario, a.cant_horas, nvl(a.cant_horas_sem,0) cant_horas_sem, nvl(a.cant_horas_mes,0) cant_horas_mes, nvl(to_char(a.hora_entrada_desde,'HH12:MI AM'),'') hora_entrada_desde, nvl(to_char(a.hora_entrada_hasta,'HH12:MI AM'),'') hora_entrada_hasta, nvl(to_char(a.hora_salida_desde,'HH12:MI AM'),'') hora_salida_desde, nvl(to_char(a.hora_salida_hasta,'HH12:MI AM'),'') hora_salida_hasta, nvl(a.maxper_horas_extras,0) maxper_horas_extras, nvl(a.verificar_comida,'N') verificar_comida, nvl(a.horas_com,0) horas_com, nvl(a.minutos_com,0) minutos_com, NVL(a.cant_min_extra,0) cant_min_extra, NVL(a.tipo_extra,0) tipo_extra, decode(b.descripcion,null,'',b.descripcion) as tipo_extra_desc, NVL(a.hor_admin,'N') hor_admin FROM TBL_PLA_HORARIO_TRAB a, TBL_PLA_T_HORAS_EXT b where a.tipo_extra=b.codigo(+) and a.compania = "+session.getAttribute("_companyId")+" and a.codigo="+id;
		cdo = SQLMgr.getData(sql);
		
		sql="select tipo_comida as tipoComida from tbl_pla_comidas_x_horario where horario="+id;
		al = sbb.getBeanList(ConMgr.getConnection(), sql, Horario.class);
		if(al.size()== 1)
		{
				Horario hr = (Horario)al.get(0);
				HorDet.setTipoComida(hr.getTipoComida());
				HorDet.setTipoComida2("0");
				System.out.println("---al.size()--"+al.size());
				
		}
		else if(al.size()== 2)
		{
				Horario hr = (Horario)al.get(0);
				HorDet.setTipoComida(hr.getTipoComida());
				hr = (Horario)al.get(1);
				HorDet.setTipoComida2(hr.getTipoComida());
		}
		else
		{
				HorDet.setTipoComida("0");
				HorDet.setTipoComida2("0");
		}
				
		sql = "SELECT secuencia, compania, cod_horario codigo, dia dias, TO_CHAR(hora_entrada,'HH12:MI AM') horaent, TO_CHAR(hora_salida,'HH12:MI AM') horasal, libre, TO_CHAR(hora_salida_almuerzo,'HH12:MI AM') horasalalm, TO_CHAR(hora_entrada_almuerzo,'HH12:MI AM') horaentalm, TO_CHAR(hora_gracia_entrada,'HH12:MI AM') horagraciaent, verificar_comida verificarcomida, TO_CHAR(hora_entrada_desde,'HH12:MI AM') horaentdesde, decode(hora_entrada_hasta,null,'', TO_CHAR(hora_entrada_hasta,'HH12:MI AM')) horaenthasta, TO_CHAR(hora_salida_desde,'HH12:MI AM') horasaldesde, TO_CHAR(hora_salida_hasta,'HH12:MI AM') horasalhasta, cant_horas canthoras, horas_com horacomida, minutos_com minutoscomida FROM TBL_PLA_HORARIO_EXCEPCIONES WHERE compania = "+session.getAttribute("_companyId")+" and cod_horario="+id;
		if (change==null){
			HorDet.setExcepciones(sbb.getBeanList(ConMgr.getConnection(), sql, Horario.class));
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Recursos Humanos - '+document.title;
function chkNullValues(){
	var x = 0;
	var msg ='';
	if(document.form1.hora_entrada.value=="" || document.form1.hora_salida.value=="")
	{if(document.form1.hora_entrada.value==""){
		msg+='  Hora de Entrada ';
		x++;
	}if(document.form1.hora_salida.value==""){
		msg+='  Hora de Salida';
		x++;
		}
		alert('Seleccione valor en '+msg);
	}
	if(document.form1.tipo_comida.value !="0" ||document.form1.tipo_comida2.value !="0")
	if(document.form1.tipo_comida.value == document.form1.tipo_comida2.value)
	{
			alert('No puede tener los mismos tipos de comida');
			x++;
	}		
	if(x>0)	return false;
	else return true;
	
}
function addExcep()
{
	abrir_ventana1('../rhplanilla/reg_excepcion.jsp?mode=<%=mode%>&id=<%=id%>');
}

function addExtra()
{
    abrir_ventana1('../common/search_horasextras.jsp?fp=horario_trab');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CREAR HORARIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ==================   F O R M   S T A R T   H E R E   =================== -->
        <%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
            <tr>
                <td colspan="6">&nbsp;</td>
            </tr>
			  
			<tr class="TextRow02">
					<td colspan="6" align="right">&nbsp;</td>
			</tr>
            
			<tr class="TextPanel">
                <td colspan="6">&nbsp;Horarios</td>
            </tr>
            
			<tr class="TextRow01" >
                <td width="13%">&nbsp;C&oacute;digo</td>
                <td width="21%" col>&nbsp;<%=fb.intBox("codigo",(cdo.getColValue("codigo")!=null)?cdo.getColValue("codigo"):"0",true,true,false,10,4,null,null,"")%></td>
                <td width="11%">&nbsp;Descripci&oacute;n</td>
                <td width="45%" colspan="3">&nbsp;<%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,viewMode,70,50,null,null,"")%> </td>
            </tr>
            
			<tr class="TextRow01" >
                <td>Hora de Entrada</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_entrada" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada")==null)?"":cdo.getColValue("hora_entrada")%>" />
				</jsp:include>
                </td>
                <td>&nbsp;Desde</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_entrada_desde" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada_desde")==null)?"":cdo.getColValue("hora_entrada_desde")%>" />
				</jsp:include>
                </td>
                <td>&nbsp;Hasta</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_entrada_hasta" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada_hasta")==null)?"":cdo.getColValue("hora_entrada_hasta")%>" />
				</jsp:include>
                </td>
            </tr>
            
			<tr class="TextRow01" >
                <td>&nbsp;Marcar Comida?</td>
                <td>&nbsp;<%=fb.checkbox("verificar_comida",cdo.getColValue("verificar_comida"),(cdo.getColValue("verificar_comida")!=null && cdo.getColValue("verificar_comida").equals("S")?true:false),false)%>
								<%=fb.intBox("horas_com",cdo.getColValue("horas_com"),false,false,viewMode,3,1,null,null,"")%>Hrs <%=fb.intBox("minutos_com",cdo.getColValue("minutos_com"),false,false,viewMode,3,2,null,null,"")%>Min</td>
                <td>&nbsp;Salida</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_salida_almuerzo" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida_almuerzo")==null)?"":cdo.getColValue("hora_salida_almuerzo")%>" />
				</jsp:include>
			
                </td>
                <td>&nbsp;Entrada</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_entrada_almuerzo" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_entrada_almuerzo")==null)?"":cdo.getColValue("hora_entrada_almuerzo")%>" />
				</jsp:include>
                </td>
            </tr>
            
			<tr class="TextRow01" >
                <td>Hora de Salida</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_salida" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida")==null)?"":cdo.getColValue("hora_salida")%>" />
				</jsp:include>
                </td>
                <td>&nbsp;Desde</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_salida_desde" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida_desde")==null)?"":cdo.getColValue("hora_salida_desde")%>" />
				</jsp:include>
                </td>
                <td>&nbsp;Hasta</td>
                <td>&nbsp;
                <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora_salida_hasta" />
				<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora_salida_hasta")==null)?"":cdo.getColValue("hora_salida_hasta")%>" />
				</jsp:include>
                </td>
            </tr>
            </table></td>
        </tr>
        
		<tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextPanel">
                <td colspan="4">&nbsp;Horas Laborales</td>
        	  </tr>
            
			  <tr class="TextRow01" >
                <td width="15%">&nbsp;D&iacute;as Laborables</td>
                <td width="25%">&nbsp;<%=fb.textBox("dias",cdo.getColValue("dias"),true,false,false,25,7,null,null,"")%></td>
                <td width="25%">&nbsp;Horas Laborables(Diarias)</td>
                <td width="35%">&nbsp;<%=fb.decBox("cant_horas",cdo.getColValue("cant_horas"),true,false,false,25,3.2,null,null,"")%></td>
              </tr>
            
			  <tr class="TextRow01" >
                <td>&nbsp;Tipo de Comida 1</td>
                <td>&nbsp;<%=fb.select("tipo_comida","0= Ninguna,1=Refrigerio,2=Desayuno,3=Almuerzo,4=Cena",HorDet.getTipoComida(),false,false,0,"",null,"")%></td>
                <td>&nbsp;Horas Laborables(Semanales)</td>
                <td>&nbsp;<%=fb.decBox("cant_horas_sem",cdo.getColValue("cant_horas_sem"),false,false,false,25,3.2,null,null,"")%></td>
              </tr>
            
			  <tr class="TextRow01" >
                <td>&nbsp;Tipo de Comida 2</td>
                <td>&nbsp;<%=fb.select("tipo_comida2","0=Ninguna,1=Refrigerio,2=Desayuno,3=Almuerzo,4=Cena",HorDet.getTipoComida2(),false,false,0,"",null,"")%></td>
                <td>&nbsp;Horas Laborables(Mensuales)</td>
                <td>&nbsp;<%=fb.decBox("cant_horas_mes",cdo.getColValue("cant_horas_mes"),false,false,false,25,3.2)%></td>
              </tr>
					  
              <tr class="TextRow01">
                <td>&nbsp;Comentario</td>
				<td colspan="2"><%=fb.textarea("comentario",cdo.getColValue("comentario"),false,false,false,50,3,2000,"","width:100%","")%></td>
				<td>&nbsp;Horas para Admin.&nbsp;<%=fb.select("hor_admin","N=No,S=Si",cdo.getColValue("hor_admin"),false,viewMode,0,"",null,null)%></td> 
              </tr>
            
			  <tr class="TextRow01">
                <td colspan="4" align="right">&nbsp;<%=fb.button("excepcion","Excepciones",true,false,null,null,"onClick=\"javascript:addExcep(id)\"")%></td>
              </tr>
			
			  <tr class="TextRow02">
				<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			  </tr>
            </table></td>
        </tr>
        
		<tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%
			fb.appendJsValidation("\n\tif (!chkNullValues()) error++;\n");
		%>
        <%=fb.formEnd(true)%>
        <!-- ==================   F O R M   E N D   H E R E   =================== -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();
	HorDet.getComidas().clear();
	String companyId = (String) session.getAttribute("_companyId");
	HorDet.setCompania(companyId);
	HorDet.setDescripcion(request.getParameter("descripcion"));
	if(request.getParameter("hora_entrada") != null && !request.getParameter("hora_entrada").trim().equals("") && !request.getParameter("hora_entrada").trim().equals("null"))
	HorDet.setHoraEnt(request.getParameter("hora_entrada"));
	else HorDet.setHoraEnt("");
	HorDet.setHoraSal(request.getParameter("hora_salida"));
	HorDet.setDias(request.getParameter("dias"));
	HorDet.setHoraSalAlm(request.getParameter("hora_salida_almuerzo"));
	HorDet.setHoraEntAlm(request.getParameter("hora_entrada_almuerzo"));
	HorDet.setComentario(request.getParameter("comentario"));
	HorDet.setCantHoras(request.getParameter("cant_horas"));
	HorDet.setCantHorasSem(request.getParameter("cant_horas_sem"));
	HorDet.setCantHorasMes(request.getParameter("cant_horas_mes"));
	HorDet.setHoraEntDesde(request.getParameter("hora_entrada_desde"));
	HorDet.setHoraEntHasta(request.getParameter("hora_entrada_hasta"));
	HorDet.setHoraSalDesde(request.getParameter("hora_salida_desde"));
	HorDet.setHoraSalHasta(request.getParameter("hora_salida_hasta"));
	HorDet.setTipoExtra("");
	HorDet.setCantMinExtra("");

	System.out.println("Geetesh Printing Cantidad de horas#######################################"+request.getParameter("cant_horas"));
	
	if(request.getParameter("verificar_comida")!=null) HorDet.setVerificarComida("S");
	else HorDet.setVerificarComida("N");
	HorDet.setHorasComida(request.getParameter("horas_com"));
	HorDet.setMinutosComida(request.getParameter("minutos_com"));
	if(request.getParameter("tipo_comida")!=null && !request.getParameter("tipo_comida").trim().equals("0"))
	{
		HorDet.setTipoComida(request.getParameter("tipo_comida"));
	}else HorDet.setTipoComida("");
	if(request.getParameter("tipo_comida2")!=null && !request.getParameter("tipo_comida2").trim().equals("0"))
	{
		HorDet.setTipoComida2(request.getParameter("tipo_comida2"));
	}else HorDet.setTipoComida2("");
	//HorDet.setTipoExtra(""+request.getParameter("tipo_extra"));
	//HorDet.setCantMinExtra(""+request.getParameter("cant_min_extra"));
	HorDet.setHoraAdmin(""+request.getParameter("hor_admin"));

	if (mode.equalsIgnoreCase("add")){
		HorMgr.add(HorDet);
	} else {
		HorDet.setCodigo(""+request.getParameter("id"));
		HorMgr.update(HorDet);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (HorMgr.getErrCode().equals("1")){
%>
	alert('<%=HorMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/horarios_list.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/horarios_list.jsp")%>';
<%
	} else {
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/horarios_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(HorMgr.getErrMsg());
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
