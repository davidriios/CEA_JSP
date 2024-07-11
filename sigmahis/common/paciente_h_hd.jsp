<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactTransaccion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SQLMgr.setConnection(ConMgr);
String sql = "";
String pacienteId = request.getParameter("pacienteId");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String action = request.getParameter("action");

String mode = request.getParameter("mode");
boolean viewMode = true;

if (fp == null) fp = "";
if (fg == null) fg = "";
if (pacienteId == null) pacienteId = "";
if (action == null ) action = "";

if (mode == null) mode = "add";

if (pacienteId.equals("")){
   sql = "select 0 exp_id, ' ' nombre_paciente, 0 codigo_paciente, ' ' cedulaPasaporte, ' ' fecha_nacimiento, 0 edad, 0 edad_mes, 0 edad_dias , ' ' sexo, ' ' jubilado, 0 provincia, 0 tomo,0 asiento, ' ' sigla, 0 pac_id, 0 religion ,0 comida from dual";
}else{
  sql = "select p.exp_id, p.nombre_paciente, p.codigo codigo_paciente, decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento,p.pasaporte)||decode(p.d_cedula,'D',null,'-'||p.d_cedula) as cedulaPasaporte, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, p.edad, p.edad_mes, p.edad_dias , p.sexo, p.jubilado, p.provincia, p.tomo, p.asiento, p.sigla, p.pac_id, p.religion ,(select nvl(comida_id,0)  from tbl_adm_paciente where pac_id = "+pacienteId+") comida from vw_adm_paciente p where p.pac_id = "+pacienteId;
}

System.out.println("SQL:\n"+sql);

cdo = SQLMgr.getData(sql);

%>
<script language="javascript">
	function createAdmision(){
	   //openWin("<%=request.getContextPath()%>/admision/admision_config.jsp?fp=hdadmision&pacId=<%=pacienteId%>","Paciente","");
     //openWin("<%=request.getContextPath()%>/admision/admision_config.jsp?fp=hdadmision&pacId=<%=pacienteId%>");
	  window.open("<%=request.getContextPath()%>/admision/admision_config.jsp?fp=hdadmision&pacId=<%=pacienteId%>","Paciente","scrollbars=1");
	}
</script>

<table width="100%" cellpadding="1" cellspacing="1">
	<%fb = new FormBean("paciente",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("edad",cdo.getColValue("edad"))%>
	<%=fb.hidden("edad_mes",cdo.getColValue("edad_mes"))%>
	<%=fb.hidden("edad_dias",cdo.getColValue("edad_dias"))%>
	<%=fb.hidden("provincia",cdo.getColValue("provincia"))%>
	<%=fb.hidden("sigla",cdo.getColValue("sigla"))%>
	<%=fb.hidden("tomo",cdo.getColValue("tomo"))%>
	<%=fb.hidden("asiento",cdo.getColValue("asiento"))%>
	<%=fb.hidden("pacienteId",cdo.getColValue("pac_id"))%>
	<%=fb.hidden("codigoPaciente",cdo.getColValue("codigo_paciente"))%>
	<tr class="TextResultRowsWhite">
		<td width="5%"><cellbytelabel id="1">ExpId</cellbytelabel></td>
		<td width="5%"><%=fb.intBox("expedienteId",cdo.getColValue("exp_id"),false,false,true,4,"Text10",null,null)%></td>
		<td width="7%" align="right"><cellbytelabel id="2">Nombre</cellbytelabel></td>
		<td width="27%"><%=fb.textBox("nombrePaciente",cdo.getColValue("nombre_paciente"),!viewMode,false,true,36,"Text10",null,null)%></td>
		<td width="7%"><cellbytelabel id="3">C&eacute;d/Pasa.</cellbytelabel></td>
		<td width="10%"><%=fb.textBox("cedulaPasaporte",cdo.getColValue("cedulaPasaporte"),false,false,true,16,"Text10",null,null)%></td>
		<td width="10%" align="right"><cellbytelabel id="4">Fecha Nac.</cellbytelabel></td>
		<td width="10%"><%=fb.textBox("fechaNacimiento",cdo.getColValue("fecha_nacimiento"),false,false,true,9,"Text10",null,null)%></td>
		<td width="19%"><cellbytelabel id="5">Edad</cellbytelabel>
			<label id="lbl_edad"><%=cdo.getColValue("edad")%></label>
			a&nbsp;
			<label id="lbl_edad_mes"><%=cdo.getColValue("edad_mes")%></label>
			m&nbsp;
			<label id="lbl_edad_dias"><%=cdo.getColValue("edad_dias")%></label>
			d&nbsp;
		</td>
			
	</tr>
	<tr class="TextResultRowsWhite">
		<td width="5%"><cellbytelabel id="6">Sexo</cellbytelabel></td>
		<td width="5%"><%=fb.textBox("sexo",cdo.getColValue("sexo"),false,false,true,4,"Text10",null,null)%></td>
		<td width="90%" colspan="7">
		  
		  <table width="100%">
			  <tr class="TextResultRowsWhite">
				 <td width="7%"><cellbytelabel id="7">Jubilado</cellbytelabel></td>
				 <td width="3%"><%=fb.checkbox("jubilado",cdo.getColValue("jubilado"),(cdo.getColValue("jubilado")!= null && cdo.getColValue("jubilado").equals("S")),viewMode)%></td>
				 <td width="20%" align="right"><cellbytelabel id="8">Comida</cellbytelabel></td>
		         <td width="10%"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from TBL_ADM_comida ","comida",cdo.getColValue("comida"),false,true,0,"Text10",null,null,"","")%></td>
	            <td width="60%" align="center">
				<%=fb.button("btnCreateAdm","Crear Admisión",true,!(action.equals("check")&&!pacienteId.equals("")),null,"Text10","onClick=\"javascript:createAdmision()\"")%>
				<%if(!action.equals("")){%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
				<%}%>
				</td>
			  </tr>
		  </table>
		
		</td>
	</tr>
	<!--<tr class="TextResultRowsWhite">
		<td align="left" colspan="8">
		No. Adm.
		<%//=fb.intBox("admSecuencia","",false,false,true,3,"Text10",null,null)%>
		Ingreso&nbsp;
		<%//=fb.textBox("fechaIngreso","",!viewMode,false,true,10,"Text10",null,null)%>
		<%//=fb.select("mesCta","ENE=ENERO,FEB=FEBRERO,MAR=MARZO,ABR=ABRIL,MAY=MAYO,JUN=JUNIO,JUL=JULIO,AGO=AGOSTO,SEP=SEPTIEMBRE,OCT=OCTUBRE,NOV=NOVIEMBRE,DIC=DICIEMBRE","",false,true,0,"Text10",null,null,"","S")%>&nbsp;
		Cama&nbsp;
		<%//=fb.textBox("cama","",false,false,true,6,"Text10",null,null)%>
		Area/Centro Adm.&nbsp;
		<%//=fb.textBox("cds",cdo.getColValue("centro_servicio"),false,false,true,2,"Text10",null,null)%>
		<%//=fb.textBox("cdsDesc","",false,false,true,15,"Text10",null,null)%>
			Categor&iacute;a&nbsp;
			<%//=fb.intBox("categoria","",!viewMode,false,true,1,"Text10",null,null)%>
			<%//=fb.textBox("categoriaDesc","",!viewMode,false,true,20,"Text10",null,null)%>
	</td>
	</tr>-->
	
	<!--<tr class="TextResultRowsWhite">
		<td width="81%" align="left"><%
	//if(fp.equals("mat_paciente") && fg.equals("SOP")){
	%>
			M&eacute;dico que ejecuta la cirug&iacute;a
			<%//} else {%>
			M&eacute;dico Atiende
			<%//}%>
			<%//=fb.textBox("medico","",false,false,true,4,"Text10",null,null)%>
			<%//=fb.textBox("nombreMedico","",false,false,true,34,"Text10",null,null)%>
			<%//=fb.hidden("medicoNombres","")%>
			<%//=fb.hidden("medicoApellidos","")%>
			<%
			//if(fp.equals("mat_paciente") && fg.equals("SOP")){
			%>
			<%//=fb.button("btnMedico","...",true,viewMode,null,"Text10","onClick=\"javascript:showMedicoList()\"")%>
			<%//}%>
			M&eacute;dico Cabecera
			<%//=fb.textBox("medicoCabecera","",false,false,true,4,"Text10",null,null)%>
			<%//=fb.textBox("nombreMedicoCabecera","",false,false,true,34,"Text10",null,null)%>
		</td>
	 <td width="19%" align="left">Relig.<%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion from TBL_ADM_RELIGION ","religion",cdo.getColValue("religion"),false,true,0,"Text10",null,null,"","")%>
		</td>
	</tr>-->
	<!--<tr class="TextResultRowsWhite">
		<td align="left" colspan="8">
		Area de Atención
		<%//=fb.textBox("cdsAtencion","",false,false,true,2,"Text10",null,null)%>
		<%//=fb.textBox("cdsAtencionDesc","",false,false,true,15,"Text10",null,null)%>
	</td>
	</tr>-->
	<%=fb.formEnd(true)%>
</table>
