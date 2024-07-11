<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.AreasCorporalPaciente"%>
<%@ page import="issi.expediente.CaracteristicasAreas"%>
<%@ page import="issi.expediente.SubCaracteristicasAreas"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="EFMgr" scope="page" class="issi.expediente.ExamenFisicoMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EFMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
int subDetTot = 0;
String fg = request.getParameter("fg");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String cds = request.getParameter("cds");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (cds == null) cds = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";
if (desc == null) desc = "";
if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{	
	sql = "select * from (select a.orden, c.sec_orden, a.codigo as codArea, 0 as codCarac, a.descripcion, nvl(b.normal,' ') as status, nvl(b.observaciones,' ') as observacion from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c where a.codigo=b.cod_area(+) and a.codigo = c.cod_area  and c.centro_servicio ="+cds+" /*a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+")*/ and a.usado_por in('T','M') union select a.orden, c.sec_orden, a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' ') from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area_corp, observacion, cod_caract_corp from tbl_sal_prueba_fisica where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c   where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp = c.cod_area  and c.centro_servicio ="+cds+" /*a.cod_area_corp in (select distinct cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+")*/ and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+") and a.usado_por in('T','M') ) order by 2,3,4";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<%if(fg.equalsIgnoreCase("proc_y_cirugia_ambu")){%>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<%}%>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - Examen Físico - '+document.title;
var s = "<%=sql%>";
function doAction(){}
function showDetail(k,status){var area=eval('document.form0.codArea'+k).value;var obj=document.getElementById('detail'+area);if(status=='N'){eval('document.form0.observacion'+k).readOnly=false;eval('document.form0.observacion'+k).className='FormDataObjectEnabled form-control input-sm';obj.style.display='none';}else if(status=='A'){eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled form-control input-sm';eval('document.form0.observacion'+k).value='';obj.style.display='';}else{eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled form-control input-sm';eval('document.form0.observacion'+k).value='';obj.style.display='none';}doAction();}
function showObservation(k){
    if(eval('document.form0.status'+k).checked){
        eval('document.form0.observacion'+k).readOnly = false;
        eval('document.form0.observacion'+k).className='FormDataObjectEnabled form-control input-sm';
        manageSubDet(k);
    } else {
        eval('document.form0.observacion'+k).readOnly = true;
        eval('document.form0.observacion'+k).className='FormDataObjectDisabled form-control input-sm';
        eval('document.form0.observacion'+k).value='';
        manageSubDet(k, 'clean');
    }
}
function verifyObservation(){var error=0;for(i=0;i<<%=al.size()%>;i++){if(eval('document.form0.codCarac'+i).value!='0'){if(eval('document.form0.status'+i).checked&&eval('document.form0.observacion'+i).value.trim()==''){error++;break;}}}if(error>0)return false;else return true;}
function imprimirExp(){abrir_ventana('../expediente3.0/print_examen_fisico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&seccion=<%=seccion%>&desc=<%=desc%>');}

function manageSubDet(i, opt) {
  if (opt && opt == 'clean') {
    $('.sub_status_'+i).prop('checked', false);
    $('.observacion_'+i).prop('readOnly', true).val("");
  }
  $('.sub_detail_'+i).toggle()
}

function manageSubDetObs(i, d) {
  if ( !$("#sub_status_"+i+"_"+d).is(":checked") )
    $("#observacion_"+i+"_"+d).prop('readOnly', true).val("");
  else $("#observacion_"+i+"_"+d).prop('readOnly', false);
}
</script>
<style>
table {width: 100%;border-collapse: collapse;}
td, th {padding: .25em;border: 1px solid black;}
tbody:nth-child(odd) {background: #CCC;}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
  <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
  <%=fb.formStart(true)%> <%=fb.hidden("baction","")%> 
  <%=fb.hidden("mode",mode)%>
  <%=fb.hidden("modeSec",modeSec)%>
  <%=fb.hidden("seccion",seccion)%> <%=fb.hidden("size",""+al.size())%>
  <%if(fg.trim().equals("proc_y_cirugia_ambu")){%>
    <%=fb.hidden("dob",fechaNacimiento)%>
    <%=fb.hidden("codPac",codigoPaciente)%>
  <%} else {%>
    <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
    <%=fb.hidden("dob","")%>
    <%=fb.hidden("codPac","")%>
  <%}%>
  <%=fb.hidden("pacId",pacId)%>
  <%=fb.hidden("noAdmision",noAdmision)%> 
  <%=fb.hidden("cds",""+cds)%>
  <%=fb.hidden("desc",desc)%>
  <%=fb.hidden("fg",fg)%>
  <%=fb.hidden("fecha_nacimiento", fechaNacimiento)%>
  <%=fb.hidden("codigo_paciente", codigoPaciente)%>
  
  <div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
        <tr>
            <td>
                <%=fb.button("imprimir","Imprimir",true,false,null,null,"onClick=\"javascript:imprimirExp()\"")%>
            </td>
      </tr>
    </table>
  </div>    
      
  <table cellspacing="0" class="table table-small-font table-bordered">
      <tr class="bg-headtabla">
        <th width="32%"><cellbytelabel id="2">&Aacute;rea</cellbytelabel></th>
        <th width="10%"><cellbytelabel id="3">No Evaluado</cellbytelabel></th>
        <th width="7%"><cellbytelabel id="4">Normal</cellbytelabel></th>
        <th width="7%"><cellbytelabel id="5">Anormal</cellbytelabel></th>
        <th width="44%"><cellbytelabel id="6">Observaci&oacute;n del &Aacute;rea</cellbytelabel></th>
      </tr>
      <%
        String area = "";
        for (int i=0; i<al.size(); i++) {
        cdo = (CommonDataObject) al.get(i);

        boolean isReadOnly = false;
        String displayDetail = "none";
        if (cdo.getColValue("codCarac").equals("0")){
            isReadOnly = (viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("N"));
            if (cdo.getColValue("status").trim().equalsIgnoreCase("A")) displayDetail = "''";
        } else {
            isReadOnly = (viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("S"));
        }
      %>
      <%=fb.hidden("codArea"+i,cdo.getColValue("codArea"))%>
      <%=fb.hidden("codCarac"+i,cdo.getColValue("codCarac"))%>
      <% if (area.equals(cdo.getColValue("codArea"))) {
      
        ArrayList alSubDet = SQLMgr.getDataList("select a.codigo, a.descripcion, d.seleccionar sub_status, d.observacion from tbl_sal_sub_carat_areas_corp a, tbl_sal_prueba_fisica_det d where d.cod_area_corp(+) = a.cod_area_corp and d.cod_sub_caract(+) = a.codigo and d.cod_caract_corp(+) = a.cod_caract and d.pac_id(+) = "+pacId+" and d.admision(+) = "+noAdmision+" and a.cod_area_corp = "+cdo.getColValue("codArea")+" and a.cod_caract = "+cdo.getColValue("codCarac")+" order by a.orden ");
        
        
      
      %>
      <tbody>
      <tr>
        <td>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("descripcion")%></td>
        <td align="center"><%=fb.checkbox("status"+i,"S",cdo.getColValue("status").trim().equalsIgnoreCase("S"),viewMode,null,null,"onClick=\"javascript:showObservation("+i+")\"")%></td>
        <td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("S")),40,1,2000,"form-control input-sm","","")%></td>
      </tr>
      </tbody>
      <%for (int d = 0; d < alSubDet.size(); d++){
      CommonDataObject cdoD = (CommonDataObject) alSubDet.get(d);
      subDetTot++;
      %>
      <%%>
      <tr class="sub_detail_<%=i%>" style="display:<%=cdo.getColValue("status")!=null&&cdo.getColValue("status").equalsIgnoreCase("S")?"":"none"%>">
         <%=fb.hidden("cod_sub_caract_"+i+"_"+d, cdoD.getColValue("codigo"))%>
         <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdoD.getColValue("descripcion")%></td>
         <td align="center">
            <%=fb.checkbox("sub_status_"+i+"_"+d,"S", cdoD.getColValue("sub_status")!=null&&cdoD.getColValue("sub_status").trim().equalsIgnoreCase("S"),viewMode,"sub_status_"+i,null,"onclick='manageSubDetObs("+i+", "+d+")'")%>
         </td>
         <td>
           <%=fb.textarea("observacion_"+i+"_"+d, cdoD.getColValue("observacion"),false,false,(viewMode || !cdoD.getColValue("sub_status").trim().equalsIgnoreCase("S")),40,1,2000,"form-control input-sm observacion_"+i,"","")%>
         </td>
      </tr>
      <%}%>
      
      <% } else {
        if (i != 0) {%>
    </table></td>
  </tr>
<%
		}
%>
		<tbody>
		<tr>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=fb.radio("status"+i,"",cdo.getColValue("status").trim().equals(""),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td align="center"><%=fb.radio("status"+i,"N",cdo.getColValue("status").trim().equalsIgnoreCase("N"),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td align="center"><%=fb.radio("status"+i,"A",cdo.getColValue("status").trim().equalsIgnoreCase("A"),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("N")),40,1,2000,"form-control input-sm","","")%></td>
		</tr>
		</tbody>
		<tr id="detail<%=cdo.getColValue("codArea")%>" style="display:<%=displayDetail%>">
			<td colspan="5">
				<table class="table table-small-font table-bordered">
                    <tr class="bg-headtabla2" align="center">
                        <th width="45%"><cellbytelabel id="7">Caracter&iacute;sticas Anormales</cellbytelabel></th>
                        <th width="5%"><cellbytelabel id="8">S&iacute;</cellbytelabel></th>
                        <th width="50%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></th>
                    </tr>
<%
	} //end else
	if (i + 1 == al.size())
	{
%>
				</table>
            </td>
		</tr>
<%
	}
	area = cdo.getColValue("codArea");
}//for
%>
		<tr class="TextRow02" align="right">
			<td colspan="5">
				<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%></td>
		</tr>
        <%=fb.hidden("sub_det_tot", ""+subDetTot)%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	int sizeSubDet = Integer.parseInt(request.getParameter("sub_det_tot"));

	Hashtable htHash = new Hashtable();
	al.clear();
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("codCarac"+i).equals("0"))
		{
			if (request.getParameter("status"+i) != null && !request.getParameter("status"+i).trim().equals(""))
			{
				AreasCorporalPaciente area = new AreasCorporalPaciente();

				area.setCodPaciente(request.getParameter("codPac"));
				area.setFecNacimiento(request.getParameter("dob"));
				area.setPacId(request.getParameter("pacId"));
				area.setSecuencia(request.getParameter("noAdmision"));
//				area.setCodCaractCorp(request.getParameter("codCarac"+i));
				area.setCodArea(request.getParameter("codArea"+i));
				area.setObservaciones(request.getParameter("observacion"+i));
				area.setNormal(request.getParameter("status"+i));

				try
				{
					htHash.put(area.getCodArea(), area);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//area
		else
		{
			if (request.getParameter("status"+i) != null)
			{
                CaracteristicasAreas carac = new CaracteristicasAreas();
                AreasCorporalPaciente areaTmp = new AreasCorporalPaciente();
                
                for (int d = 0; d < sizeSubDet; d++) {
                    String status = request.getParameter("sub_status_"+i+"_"+d);
                    if ( status != null ) {
                        SubCaracteristicasAreas subCarac = new SubCaracteristicasAreas();
                        subCarac.setCodCaractCorp(request.getParameter("codCarac"+i));
                        subCarac.setCodSubCaract(request.getParameter("cod_sub_caract_"+i+"_"+d));
                        subCarac.setCodAreaCorp(request.getParameter("codArea"+i));
                        subCarac.setSeleccionar(status!=null && status.trim().equalsIgnoreCase("S") ? "S" : "N");
                        subCarac.setObservacion(request.getParameter("observacion_"+i+"_"+d));
                        subCarac.setPacId(request.getParameter("pacId"));
                        subCarac.setAdmision(request.getParameter("noAdmision"));
                        System.out.println(".................................................>>> codCarac = "+subCarac.getCodCaractCorp());
                        
                        areaTmp.addSubCaracteristicasAreas(subCarac);
                    }
                }    

				carac.setCodPaciente(request.getParameter("codPac"));
				carac.setFecNacimiento(request.getParameter("dob"));
				carac.setPacId(request.getParameter("pacId"));
				carac.setSecuencia(request.getParameter("noAdmision"));
				carac.setCodCaractCorp(request.getParameter("codCarac"+i));
				carac.setObservacion(request.getParameter("observacion"+i));
				carac.setCodAreaCorp(request.getParameter("codArea"+i));
				carac.setValor(request.getParameter("valor"+i));
				carac.setSeleccionar(request.getParameter("status"+i));

				try{
					AreasCorporalPaciente area = (AreasCorporalPaciente) htHash.get(carac.getCodAreaCorp());

					if (area.getNormal().equals("A")){
						area.addCaracteristicasAreas(carac);
                        for (int d = 0; d<areaTmp.getSubCaracteristicasAreas().size(); d++) {
                          SubCaracteristicasAreas subCaracTmp = (SubCaracteristicasAreas) areaTmp.getSubCaracteristicasAreas().get(d);
                          System.out.println("............................... Observacion"+d+" = "+subCaracTmp.getObservacion());
						  area.addSubCaracteristicasAreas(subCaracTmp);
                        }
					}

					htHash.put(area.getCodArea(),area);
				}
				catch(Exception e){
					System.err.println(e.getMessage());
				}
			}
		}
	}//for

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg);
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		EFMgr.add(htHash,request.getParameter("pacId"),request.getParameter("noAdmision"));
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (EFMgr.getErrCode().equals("1"))
{
%>
	alert('<%=EFMgr.getErrMsg()%>');
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
} else throw new Exception(EFMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>