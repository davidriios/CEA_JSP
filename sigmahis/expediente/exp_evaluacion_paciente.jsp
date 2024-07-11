<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDiagPost" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPost" scope="session" class="java.util.Vector" />
<jsp:useBean id="iMuestra" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMuestra" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Hashtable ht = null;
boolean viewMode = false;
String sql = "";
String code ="0";
String mode ="";
String seccion = "";
String pacId = "";
String noAdmision = "";
String fg ="";
String tab = "";
String desc = "";
String subTipo = "";
String exp = "";

int totImg = 4;

	if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
	{
		 ht = CmnMgr.getMultipartRequestParametersValue(request,ResourceBundle.getBundle("path").getString("expedientedocs"),20,true);
		 mode = (String) ht.get("mode");
		 seccion = (String) ht.get("seccion");
		 pacId = (String) ht.get("pacId");
		 noAdmision = (String) ht.get("noAdmision");
		 fg = (String) ht.get("fg");
		 tab = (String) ht.get("tab");
		 if(ht.get("code") != null) code = (String) ht.get("code");
		 desc = (String) ht.get("desc");
		 subTipo = (String)ht.get("sub_tipo");
		 exp = (String)ht.get("exp");

	}
	else
	{
		 mode = request.getParameter("mode");
		 seccion = request.getParameter("seccion");
		 pacId = request.getParameter("pacId");
		 noAdmision = request.getParameter("noAdmision");
		 fg = request.getParameter("fg");
		 tab = request.getParameter("tab");
		 desc = request.getParameter("desc");
		 if(request.getParameter("code") != null) code = request.getParameter("code");


	}

String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

String key = "";
String docTitle = "";
String title = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
int muestraLastLineNo = 0;
int diagPostLastLineNo  = 0;

if (tab == null) tab = "0";
if (fg.trim().equals("BR"))
{
	docTitle = "Evaluacion - Broncoscopia";
	title = "EVALUACION - BRONCOSCOPIA";
}
else if (fg.trim().equals("CR"))
{
	docTitle = "Evaluacion - Colonoscopia y Rectoscopia";
	title = "EVALUACION - COLONOSCOPIA Y RECTOSCOPIA";
}
else if (fg.trim().equals("CI"))
{
	docTitle = "Evaluacion - Cistoscopia";
	title = "EVALUACION - CISTOSCOPIA";
}
else if (fg.trim().equals("EG"))
{
	docTitle = "Evaluacion - Endoscopia Gastroduodenal";
	title = "EVALUACION - ENDOSCOPIA GASTRODUODENAL";
}

if (request.getParameter("muestraLastLineNo") != null) muestraLastLineNo = Integer.parseInt(request.getParameter("muestraLastLineNo"));
if (request.getParameter("diagPostLastLineNo") != null) diagPostLastLineNo = Integer.parseInt(request.getParameter("diagPostLastLineNo"));


if (request.getMethod().equalsIgnoreCase("GET"))
{

sql=" select a.codigo, a.tipo_evaluacion, to_char(a.fecha,'dd/mm/yyyy') fecha ,a.diag_pre_evaluacion, a.medico , d.primer_nombre||decode(d.segundo_nombre,null,'',' '||d.segundo_nombre)||' '||d.primer_apellido||decode(d.segundo_apellido,null,'',' '||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_de_casada,null,'',' '||d.apellido_de_casada)) as nombre_medico from tbl_sal_evaluacion a, tbl_adm_medico d  where a.tipo_evaluacion = '"+fg+"' and d.codigo = a.medico  and  a.pac_id="+pacId+" and a.admision="+noAdmision+"   ";

al2 = SQLMgr.getDataList(sql);

if(!code.trim().equals("0"))
{

sql=" select a.codigo, a.tipo_evaluacion, to_char(a.fecha,'dd/mm/yyyy') fecha, a.diag_pre_evaluacion codDiagPre, a.hallazgo, a.observacion, a.recomendacion, a.medico codMedico, a.tecnica, a.premedicacion, a.anestesia, a.indicacion, a.rx_tac_torax /*,a.documento*/, decode(a.documento,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.documento) as documento, decode(a.documento2,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.documento2) as documento2, decode(a.documento3,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.documento3) as documento3, decode(a.documento4,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.documento4) as documento4, decode(a.documento,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs")+"/'||a.documento) as file_path, decode(a.documento2,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs")+"/'||a.documento2) as file_path2, decode(a.documento3,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs")+"/'||a.documento3) as file_path3, decode(a.documento4,null,' ','"+ResourceBundle.getBundle("path").getString("expedientedocs")+"/'||a.documento4) as file_path4, b.descripcion descAnestesia, coalesce(c.observacion,c.nombre) descDiagPre, d.primer_nombre||decode(d.segundo_nombre,null,'',' '||d.segundo_nombre)||' '||d.primer_apellido||decode(d.segundo_apellido,null,'',' '||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_de_casada,null,'',' '||d.apellido_de_casada)) as nombre_medico,nvl(a.sub_tipo,' ') sub_tipo, gastroscopia,duodenoscopia,colangio,colonoscopia,recto from tbl_sal_evaluacion a ,tbl_sal_tipo_anestesia b ,tbl_cds_diagnostico c , tbl_adm_medico d  where a.anestesia = b.codigo(+) and a.diag_pre_evaluacion = c.codigo(+) and a.medico = d.codigo(+) and a.codigo = "+code+" and a.tipo_evaluacion = '"+fg+"' and  a.pac_id="+pacId+" and a.admision="+noAdmision;
cdo = SQLMgr.getData(sql);
if (!viewMode) mode = "edit";
}else if(code.trim().equals("0") || cdo== null )
{
			cdo = new CommonDataObject();
			cdo.addColValue("fecha",cDateTime.substring(0,10));
			cdo.addColValue("sub_tipo","");
			//Manda error cuando el codigo del medico no existe.
			//cdo.addColValue("codMedico",""+UserDet.getRefCode());
			//cdo.addColValue("nombre_medico",""+UserDet.getName());

			if (!viewMode) mode = "add";

}//else if (!viewMode) mode = "edit";

if(change == null && !code.trim().equals("0"))
{
iDiagPost.clear();
vDiagPost.clear();
iMuestra.clear();
vMuestra.clear();

sql="select a.evaluacion, a.diagnostico, a.observacion,coalesce(b.observacion,b.nombre) descDiagnostico from tbl_sal_evaluacion_diag_post a , tbl_cds_diagnostico b where a.evaluacion = "+code+" and a.diagnostico = b.codigo ";

al = SQLMgr.getDataList(sql);

for (int i=1; i<=al.size(); i++)
{
			try
			{
					CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);

					diagPostLastLineNo++;
					if (diagPostLastLineNo < 10) key = "00" + diagPostLastLineNo;
					else if (diagPostLastLineNo < 100) key = "0" + diagPostLastLineNo;
					else key = "" + diagPostLastLineNo;
					iDiagPost.put(key, cdo1);
					vDiagPost.addElement(cdo1.getColValue("diagnostico"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
}//for

sql="  select a.id,/*nvl(b.muestra,0)**/ b.muestra,a.nombre descMuestra, b.evaluacion, b.citologia, b.patologia, b.bacterias, b.baar,b.hongos from tbl_sal_tipo_muestra_eval a, tbl_sal_evaluacion_muestra b  where a.status = 'A' and b.muestra(+) = a.id and b.evaluacion(+)= "+code;

al = SQLMgr.getDataList(sql);

for (int i=1; i<=al.size(); i++)
{
			try
			{
				///diagPostLastLineNo
					CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);

					muestraLastLineNo++;
					if (muestraLastLineNo < 10) key = "00" + muestraLastLineNo;
					else if (muestraLastLineNo < 100) key = "0" + muestraLastLineNo;
					else key = "" + muestraLastLineNo;
					iMuestra.put(key, cdo1);

			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
}//for


if (!viewMode) mode = "edit";

}//change
//else if (!viewMode) mode = "edit";

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - <%=docTitle%> - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function medicoList()
{
	abrir_ventana1('../common/search_medico.jsp?fp=exp_informes');
}
function doAction()
{
	newHeight();
	checkViewMode();
	//parent.setHeight('secciones',document.body.scrollHeight);

	<%if(request.getParameter("type") != null){%>
	abrir_ventana1('../common/check_diagnostico.jsp?seccion=<%=seccion%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&fg=<%=fg%>&fp=informes&muestraLastLineNo=<%=muestraLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&exp<%=exp%>');
	<%}%>
}
function imprimir()
{
//var fecha = document.form0.fecha.value;
abrir_ventana1('../expediente/print_evaluacion_paciente.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&tot_img=<%=totImg%>');
}
function showAnestesiaList()
{
abrir_ventana1('../expediente/list_anestesia.jsp?id=3&exp=<%=exp%>');
}
function showDiagList()
{
	abrir_ventana1('../common/search_diagnostico.jsp?fp=informes&exp=<%=exp%>');
}
function setEvaluacion(k)
{
		var code = eval('document.listado.codigo'+k).value;
		window.location = '../expediente/exp_evaluacion_paciente.jsp?fg=<%=fg%>&mode=view&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&exp=<%=exp%>&code='+code;
}
function add()
{
window.location = '../expediente/exp_evaluacion_paciente.jsp?fg=<%=fg%>&mode=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code=0&exp=<%=exp%>';

}

function canSubmit() {
    var values = $(".documento").map(function(){
        if(this.value) return this.value
    }).toArray();
    
    if (hasDuplicate(values)) {
        parent.CBMSG.error("No puedes enviar el mismo documento varias veces.");
        return false;
    }
    
    return true;
}

function eliminar(self, code, fileName, index){ 
    top.CBMSG.confirm('Confirma que desea eliminar el escaneado',{
      btnTxt:'Si,No',
      cb: function(r){
        if (r=="Si"){
           var _exe = executeDB('<%=request.getContextPath()%>',"update tbl_sal_evaluacion set documento"+index+" = null, usuario_modificacion = '<%=(String)session.getAttribute("_userName")%>', fecha_modificacion = sysdate where pac_id = <%=pacId%> and admision = <%=noAdmision%> and codigo = "+code);
           if (_exe) {
             $.ajax({
                url: '../common/serve_dyn_content.jsp?serveTo=INF_CISTO&filePath='+fileName,
                cache: false,
                dataType: "html"
            }).done(function(data){
              if ($.trim(data) == "DELETED") location.reload(true);
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

$(function(){
    $("img[width='16']").hide(0);
    
    $(".documento").change(function(){
        var index =  this.id.replace (/[^\d]/g, '');
        $("#limpiar"+index).show(0);
    });
    
    $(".limpiar").click(function(){
        var self = $(this);
        var index = self.data('index');
        $("#documento"+index).val("");
    });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<!---<tr class="TextRow01">
		<td colspan="4" align="right"><%//if (!mode.equalsIgnoreCase("add")){%><a href="javascript:imprimir()" class="Link00">[ Imprimir ]</a> <%//}%></td>
	</tr>--->
	<tr class="TextRow01">
					<td  colspan="4">
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("desc",desc)%>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel>
                            
                            <span style="float:right">
                                <%if(!code.equals("0")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%><a href="javascript:imprimir()" class="Link00">[Imprimir]</a> 
                            
                            </span>
                            
                            
                            </td>
							
						</tr>

						<tr class="TextHeader">
							<td width="10%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="3">Fecha</cellbytelabel></td>
							<td width="80%"><cellbytelabel id="4">M&eacute;dico</cellbytelabel></td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=i%>)" style="text-decoration:none; cursor:pointer">
				<td><%=cdo1.getColValue("codigo")%></td>
				<td><%=cdo1.getColValue("fecha")%></td>
				<td><%=cdo1.getColValue("nombre_medico")%></td>
		</tr>
<%
}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>



	<tr>
		<td>
<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				 <%=fb.hidden("dob","")%>
				 <%=fb.hidden("codPac","")%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("tab","0")%>
				 <%=fb.hidden("code",code)%>
				 <%=fb.hidden("fg",fg)%>
				 <%=fb.hidden("muestraLastLineNo",""+muestraLastLineNo)%>
				 <%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
				 <%=fb.hidden("dSize",""+iDiagPost.size())%>
				 <%=fb.hidden("mSize",""+iMuestra.size())%>
				 <%=fb.hidden("codMedico",""+cdo.getColValue("codMedico"))%>
				 <%=fb.hidden("desc",desc)%>
				 <%=fb.hidden("exp",exp)%>
                 <%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>

					<tr class="TextRow02">
						<td width="20%">&nbsp;</td>
						<td width="25%">&nbsp;</td>
						<td width="25%">&nbsp;</td>
						<td width="30%">&nbsp;</td>
					</tr>
					<%if (fg.trim().equals("EG")){%>
					<!--
                    <tr class="TextRow01">
                        <td><cellbytelabel id="5">Gastroscopia</cellbytelabel><%=fb.radio("sub_tipo","GC",cdo.getColValue("sub_tipo").trim().equals("GC"),viewMode,false)%></td>
                        <td><cellbytelabel id="6">Duodenoscopia</cellbytelabel><%=fb.radio("sub_tipo","DC",cdo.getColValue("sub_tipo").trim().equals("DC"),viewMode,false)%></td>
                        <td colspan="2"><cellbytelabel id="7">CPRE(Colangio-Pancreatograf&iacute;a Endoscopica)</cellbytelabel><%=fb.radio("sub_tipo","CP",cdo.getColValue("sub_tipo").trim().equals("CP"),viewMode,false)%></td>
					</tr>
                    -->
                    
                    <tr class="TextRow01">
                        <td><cellbytelabel id="5">Gastroscopia</cellbytelabel><%=fb.checkbox("gastroscopia","GC",cdo.getColValue("gastroscopia"," ").trim().equals("GC"),viewMode,null,null,null)%></td>
                        <td><cellbytelabel id="6">Duodenoscopia</cellbytelabel><%=fb.checkbox("duodenoscopia","DC",cdo.getColValue("duodenoscopia"," ").trim().equals("DC"),viewMode,null,null,null)%></td>
                        <td colspan="2"><cellbytelabel id="7">CPRE(Colangio-Pancreatograf&iacute;a Endoscopica)</cellbytelabel><%=fb.checkbox("colangio","CP",cdo.getColValue("colangio"," ").trim().equals("CP"),viewMode,null,null,null)%></td>
					</tr>
					<%}else if (fg.trim().equals("CR")){%>
					<!--
                    <tr class="TextRow01">
                        <td><cellbytelabel id="8">Colonoscopia</cellbytelabel><%=fb.radio("sub_tipo","CC",cdo.getColValue("sub_tipo").trim().equals("CC"),viewMode,false)%></td>
                        <td colspan="3"><cellbytelabel id="9">Rectosigmoidoscopia</cellbytelabel><%=fb.radio("sub_tipo","CR",cdo.getColValue("sub_tipo").trim().equals("CR"),viewMode,false)%></td>
					</tr>
                    -->
                    <tr class="TextRow01">
                        <td><cellbytelabel id="8">Colonoscopia</cellbytelabel><%=fb.checkbox("colonoscopia","CC",cdo.getColValue("colonoscopia"," ").trim().equals("CC"),viewMode,null,null,null)%></td>
                        <td colspan="3"><cellbytelabel id="9">Rectosigmoidoscopia</cellbytelabel><%=fb.checkbox("recto","CR",cdo.getColValue("recto"," ").trim().equals("CR"),viewMode,null,null,null)%></td>
					</tr>
					<%}%>
					<tr class="TextRow01">
								<td align="right"><cellbytelabel id="3">Fecha</cellbytelabel></td>
								<td>
											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha" />
											<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
											</jsp:include>
							</td>

							<td colspan="2"> <cellbytelabel id="4">M&eacute;dico</cellbytelabel>
							<%//=fb.textBox("codMedico",cdo.getColValue("codMedico"),true,false,true,5)%>
				<%=fb.textBox("nombre_medico",cdo.getColValue("nombre_medico"),true,false,true,35)%>
				<%=fb.button("medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
				</td>

			</tr>

				<%//if(!fg.trim().equals("BR")){%>
				<tr class="TextRow01">
				<td><cellbytelabel id="10">Diagnostico Pre - Endoscopico</cellbytelabel> </td>
				<td colspan="3"><%=fb.textBox("codDiagPre",cdo.getColValue("codDiagPre"),true,false,true,8,"Text10","","")%>
				<%=fb.textBox("descDiagPre",cdo.getColValue("descDiagPre"),false,false,true,40,"Text10","","")%>
				<%=fb.button("btnDiagPre","...",true,viewMode,null,null,"onClick=\"javascript:showDiagList()\"","Diagnostico")%>
								</td>
				</tr>
				<%//}%>
				<%if(fg.trim().equals("BR")){%>
				<tr class="TextRow01">
					<td><cellbytelabel id="11">Premedicaci&oacute;n</cellbytelabel></td>
					<td colspan="3">
						<%=fb.textarea("premedicacion",cdo.getColValue("premedicacion"),false,false,viewMode,60,3,100,"","width:100%","")%></td>
				</tr>

				<tr class="TextRow01">
						<td><cellbytelabel id="12">Anestesia</cellbytelabel></td>
						<td colspan="3"><%=fb.textBox("anestesia",cdo.getColValue("anestesia"),false,false,true,2,"Text10","","")%>
					<%=fb.textBox("descAnestesia",cdo.getColValue("descAnestesia"),false,false,true,45,"Text10","","")%>
					<%=fb.button("btnAnestesia","...",true,viewMode,null,null,"onClick=\"javascript:showAnestesiaList()\"","Anestesia")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="13">Indicaciones</cellbytelabel></td>
					<td colspan="3">
						<%=fb.textarea("indicacion",cdo.getColValue("indicacion"),false,false,viewMode,60,3,2000,"","width:100%","")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="14">RX o TAC de Torax</cellbytelabel></td>
					<td colspan="3">
					<%=fb.textarea("rx_tac_torax",cdo.getColValue("rx_tac_torax"),false,false,viewMode,60,3,2000,"","width:100%","")%></td>
				</tr>
				<%}%>
				<%if(fg.trim().equals("CR") ||fg.trim().equals("EG") ){%>
				<tr class="TextRow01">
						<td width="20%"><cellbytelabel id="15">T&eacute;cnica</cellbytelabel></td>
							<td>
									<%=fb.select(ConMgr.getConnection(),"SELECT id, nombre||' - '||id, id from  tbl_sal_tecnica_evaluacion where status ='A' order by 1","tecnica",cdo.getColValue("tecnica"),false,viewMode,0,"Text10",null,null,"","S")%>
						</td>
						<td align="right">&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<%}%>
					<tr class="TextRow01">
						<td><cellbytelabel id="16">Hallazgos</cellbytelabel></td>
						<td colspan="3">
						<%=fb.textarea("hallazgo",cdo.getColValue("hallazgo"),true,false,viewMode,60,3,2000,"","width:100%","")%>
						</td>
					</tr>
                    <tr class="TextRow01">
						<td><cellbytelabel id="16">Observaci&oacute;n</cellbytelabel></td>
						<td colspan="3">
						<%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,60,3,1000,"","width:100%","")%>
						</td>
					</tr>
				<%if(fg.trim().equals("CI")){%>

				<tr class="TextRow01">
						<td><cellbytelabel id="17">Recomendaciones</cellbytelabel></td>
						<td colspan="3">
						<%=fb.textarea("recomendacion",cdo.getColValue("recomendacion"),false,false,viewMode,60,3,2000,"","width:100%","")%>
						</td>
					</tr>

				<%}%>
				<%
				  
                  for (int i = 1; i<=totImg; i++){
                  
                  String index = i == 1 ? "" : ""+i;
                  
                  String doc = cdo.getColValue("documento"+index)==null?"":cdo.getColValue("documento"+index);
				  boolean hasImage = doc.toLowerCase().endsWith(".gif") || doc.toLowerCase().endsWith(".jpg") || doc.toLowerCase().endsWith(".jpeg")|| doc.toLowerCase().endsWith(".png") || doc.toLowerCase().endsWith(".bmp") || doc.toLowerCase().endsWith(".tiff");
				
				%>
				<tr class="TextRow01">
                    <td>
                    <cellbytelabel>Documento <%=i%></cellbytelabel></td>
                    <td colspan="3">
                    <%=fb.fileBox("documento"+index,cdo.getColValue("documento"+index),false,false,40,"documento","","")%>
                    
                    
                    <% if (!doc.trim().equals("")){ %>		
                        <img src="../images/search.gif" id="scan" width="20" height="20" onClick="javascript:abrir_ventana('../common/abrir_ventana.jsp?fileName=<%=cdo.getColValue("documento"+index)%>')" style="cursor:pointer;" title="AA <%=doc%>"/>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <a href="javascript:eliminar(this,<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("file_path"+index)%>','<%=index%>')"  class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')" title="Eliminar: <%=cdo.getColValue("documento"+index)%>">X</a>
                        
                    <%} else {%>
                    <span style="display:none" class="pointer limpiar" data-index="<%=index%>" id="limpiar<%=index%>">
                        <b>limpiar</b>
                    </span>
                    <%}%>
                        </td>
                    </td>
                </tr>
                    <%}%>
                    
					<tr class="TextRow02">
						<td colspan="4" align="right">
				<cellbytelabel id="19">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="20">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="21">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>

				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
						</td>
					</tr>
					<%fb.appendJsValidation("if(error>0)doAction();");%>
					<%=fb.formEnd(true)%>
				</table>
	<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<%if (!fg.trim().equals("CI") ){%>

<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("muestraLastLineNo",""+muestraLastLineNo)%>
<%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
<%=fb.hidden("dSize",""+iDiagPost.size())%>
<%=fb.hidden("mSize",""+iMuestra.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("desc",desc)%>
				<tr class="TextHeader" >
						<td colspan="5">DIAGNOSTICOS POST-ENDOSCOPICO</td>
				</tr>
				<tr class="TextRow02">
					<td width="28%"><cellbytelabel id="22">DIAGNOSTICO</cellbytelabel></td>
					<td width="24%">&nbsp;</td>
					<td width="24%">&nbsp;</td>
					<td width="20%"><cellbytelabel id="23">OBSERVACION</cellbytelabel></td>
					<td width="4%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnostico")%></td>
				</tr>

				<%
				al.clear();
				al = CmnMgr.reverseRecords(iDiagPost);

				for (int i = 1; i <= iDiagPost.size(); i++)
				{
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";

				key = al.get(i - 1).toString();
				CommonDataObject cdo5 = (CommonDataObject) iDiagPost.get(key);

				%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("key"+i,""+key)%>
				<tr class="<%=color%>">
					<td colspan="2"><%=fb.textBox("diagnostico"+i,cdo5.getColValue("diagnostico"),true,false,true,2,"Text10","","")%>
				<%=fb.textBox("descDiagnostico"+i,cdo5.getColValue("descDiagnostico"),false,false,true,45,"Text10","","")%>
				<%//=fb.button("btnDiagPost"+i,"...",true,viewMode,null,null,"onClick=\"javascript:showDiagPost()\"","Diagnostico Post Operatorio")%></td>
				<td colspan="2">
				<%=fb.textarea("observacion"+i,cdo5.getColValue("observacion"),false,false,viewMode,60,3,2000,"","width:100%","")%>
				</td>
				<td>
				<%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
				</tr>
			<%}%>


						<tr class="TextRow02">
						<td colspan="5" align="right">
				<cellbytelabel id="19">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="20">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="21">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
						</td>
					</tr>
					<%fb.appendJsValidation("if(error>0)doAction();");%>
					<%=fb.formEnd(true)%>
				</table>
	<!-- TAB1 DIV END HERE-->
</div>
<%}
if(fg.trim().equals("BR")){%>
<!-- TAB2 DIV START HERE---------------------------------------------------------------------------------------------->

<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>

<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("muestraLastLineNo",""+muestraLastLineNo)%>
<%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
<%=fb.hidden("dSize",""+iDiagPost.size())%>
<%=fb.hidden("mSize",""+iMuestra.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("desc",desc)%>

					<tr class="TextRow02">
						<td colspan="7">&nbsp;</td>
					</tr>

					<tr class="TextHeader" align="center">
							<td width="16%" class="Text10"><cellbytelabel id="24">MUESTRA</cellbytelabel></td>
							<td width="16%" class="Text10"><cellbytelabel id="25">CITOLOGIA</cellbytelabel></td>
							<td width="16%" class="Text10"><cellbytelabel id="26">PATOLOGIA</cellbytelabel></td>
							<td width="16%" class="Text10"><cellbytelabel id="27">BACTERIAS</cellbytelabel></td>
							<td width="16%" class="Text10"><cellbytelabel id="28">BAAR</cellbytelabel></td>
							<td width="16%" class="Text10"><cellbytelabel id="29">HONGOS</cellbytelabel></td>
							<td width="4%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+iMuestra.size()+",this,1)\"","Seleccionar toda la lista!")%></td>
					</tr>

				<%
				al.clear();
				al = CmnMgr.reverseRecords(iMuestra);
				for (int i = 1; i <= iMuestra.size(); i++)
				{
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";

				key = al.get(i - 1).toString();
				CommonDataObject cdo2 = (CommonDataObject)  iMuestra.get(key);
				String event = "onFocus=\"this.select();\" onChange=\"javascript:setChecked(this,document.form2.check"+i+")\"";
				%>
					 <%=fb.hidden("remove"+i,"")%>
					 <%=fb.hidden("key"+i,key)%>
					 <%=fb.hidden("muestra"+i,cdo2.getColValue("id"))%>


					<tr class="<%=color%>">
					<td><%=fb.textBox("descMuestra"+i,cdo2.getColValue("descMuestra"),false,false,viewMode,8,"","",event)%></td>
					<td><%=fb.textBox("citologia"+i,cdo2.getColValue("citologia"),false,false,viewMode,8,"","",event)%></td>
					<td><%=fb.textBox("patologia"+i,cdo2.getColValue("patologia"),false,false,viewMode,8,"","",event)%></td>
					<td><%=fb.textBox("bacterias"+i,cdo2.getColValue("bacterias"),false,false,viewMode,8,"","",event)%></td>
					<td><%=fb.textBox("baar"+i,cdo2.getColValue("baar"),false,false,viewMode,8,"","",event)%></td>
					<td><%=fb.textBox("hongos"+i,cdo2.getColValue("hongos"),false,false,viewMode,8,"","",event)%></td>
					<td><%=fb.checkbox("check"+i,(!cdo2.getColValue("muestra").trim().equals("O"))?"S":"N",(cdo2.getColValue("muestra") != null && !cdo2.getColValue("muestra").trim().equals(""))?true:false,viewMode)%></td>
					 </tr>

	<%}
	%>
				<tr class="TextRow02">
						<td colspan="7" align="right">
				<cellbytelabel id="19">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="20">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="21">Cerrar</cellbytelabel>
		 <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
						</td>
				</tr>
		<%fb.appendJsValidation("doAction();");%>
		<%=fb.formEnd(true)%>
		</table>
	<!-- TAB2 DIV END HERE------------------------------------------------------------------------------------------>
</div>
<%}%>
<!-- MAIN DIV END HERE -->
</div>
<script type="text/javascript">
<%

String tabLabel = "'Datos Generales'";
if ( !mode.equalsIgnoreCase("add") && ( fg.equalsIgnoreCase("EG") || fg.equalsIgnoreCase("CR") || fg.equalsIgnoreCase("BR"))) tabLabel += ",'Diagnosticos post-Evaluacion'";

if (!mode.equalsIgnoreCase("add") &&  fg.equalsIgnoreCase("BR")) tabLabel += ",'Muestras'";

/*if (fg.equalsIgnoreCase("BR") && tab.equals("2")) tab = ""+(Integer.parseInt(tab)-1);*/

%>
 initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
	</td>
</tr>
</table>

</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
//System.out.println("tab = "+tab);
			if(tab.equals("0")) //
			{

				saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
				baction = (String) ht.get("baction");

					cdo = new CommonDataObject();
					cdo.setTableName("tbl_sal_evaluacion");

					cdo.addColValue("tipo_evaluacion",(String) ht.get("fg"));
					cdo.addColValue("fecha",(String) ht.get("fecha"));
					cdo.addColValue("hallazgo",(String) ht.get("hallazgo"));
					cdo.addColValue("observacion",(String) ht.get("observacion"));
					cdo.addColValue("medico",(String) ht.get("codMedico"));
                    
                    String docPath = "";
                    
                    for (int i = 1; i<=totImg; i++){
                        String index = i == 1 ? "" : ""+i;
                        docPath = (String)ht.get("documento"+index);
                        docPath = CmnMgr.cleanFile(docPath);
                        if (docPath != null && !"".equals(docPath)) cdo.addColValue("documento"+index, docPath);
                    }
					cdo.addColValue("diag_pre_evaluacion",(String) ht.get("codDiagPre"));

					if(fg.trim().equals("CI"))
					{
						cdo.addColValue("recomendacion",(String) ht.get("recomendacion"));
						//cdo.addColValue("diag_pre_evaluacion",(String) ht.get("codDiagPre"));
					}
					if(fg.trim().equals("EG") || fg.trim().equals("CR"))
					{
						cdo.addColValue("tecnica",(String) ht.get("tecnica"));
						cdo.addColValue("sub_tipo",( ((String) ht.get("sub_tipo"))==null?"":(String) ht.get("sub_tipo") ) );
                        
                        cdo.addColValue("gastroscopia", (String) ht.get("gastroscopia"));
                        cdo.addColValue("duodenoscopia",(String) ht.get("duodenoscopia"));
                        cdo.addColValue("colangio",(String) ht.get("colangio"));
                        cdo.addColValue("colonoscopia",(String) ht.get("colonoscopia"));
                        cdo.addColValue("recto",(String) ht.get("recto"));
						
					}
					if(fg.trim().equals("BR"))
					{
						cdo.addColValue("premedicacion",(String) ht.get("premedicacion"));
						cdo.addColValue("anestesia",(String) ht.get("anestesia"));
						cdo.addColValue("indicacion",(String) ht.get("indicacion"));
						cdo.addColValue("rx_tac_torax",(String) ht.get("rx_tac_torax"));
						//cdo.addColValue("diag_pre_evaluacion",(String) ht.get("codDiagPre"));

					}
					cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
					cdo.addColValue("fecha_modificacion",cDateTime);
					
					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
					if (mode.equalsIgnoreCase("add"))
					{
						cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	    				cdo.addColValue("fecha_creacion",cDateTime);
						cdo.addColValue("pac_id",pacId);
						cdo.addColValue("admision",noAdmision);
						cdo.setAutoIncCol("codigo");
						cdo.addPkColValue("codigo","");

						SQLMgr.insert(cdo);
						code = SQLMgr.getPkColValue("codigo");
					}
					else
					{
						cdo.setWhereClause("codigo="+(String) ht.get("code"));
						SQLMgr.update(cdo);
					}
					ConMgr.clearAppCtx(null);

			}
			if(tab.equals("1")) //
			{

						int size = 0;
						al.clear();
						if (request.getParameter("dSize") != null) size = Integer.parseInt(request.getParameter("dSize"));
						String itemRemoved = "";

						for (int i=1; i<=size; i++)
						{
								CommonDataObject cdo2 = new CommonDataObject();
								cdo2.setTableName("tbl_sal_evaluacion_diag_post");
								cdo2.setWhereClause("evaluacion="+request.getParameter("code"));
								cdo2.addColValue("evaluacion",request.getParameter("code"));
								cdo2.addColValue("diagnostico",request.getParameter("diagnostico"+i));
								cdo2.addColValue("descDiagnostico",request.getParameter("descDiagnostico"+i));
								cdo2.addColValue("observacion",request.getParameter("observacion"+i));
									//System.out.println("remove  ====="+request.getParameter("remove"+i));
								key = request.getParameter("key"+i);
								if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
								itemRemoved = key;
								else
								{
								 try
									{
										al.add(cdo2);
										iDiagPost.put(key,cdo2);
									}
									catch(Exception e)
									{
										System.err.println(e.getMessage());
									}
								}//else
						}//for
		if(!itemRemoved.equals(""))
		{
			vDiagPost.remove(((CommonDataObject) iDiagPost.get(itemRemoved)).getColValue("diagnostico"));
			iDiagPost.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&muestraLastLineNo="+muestraLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+request.getParameter("code")+"&fg="+request.getParameter("fg")+"&diagPostLastLineNo="+diagPostLastLineNo+"&desc="+desc);
				return;
		}
		if(baction.equals("+"))//Agregar
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&muestraLastLineNo="+muestraLastLineNo+"&diagPostLastLineNo="+diagPostLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+request.getParameter("code")+"&fg="+request.getParameter("fg")+"&type=1&desc="+desc);

		}

				if (baction.equalsIgnoreCase("Guardar"))
				{
					if (al.size() == 0)
					{
						CommonDataObject cdo1 = new CommonDataObject();

						cdo1.setTableName("tbl_sal_evaluacion_diag_post");
						cdo1.setWhereClause("evaluacion="+request.getParameter("code"));
						al.add(cdo1);
					}

					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
					SQLMgr.insertList(al);
					ConMgr.clearAppCtx(null);
				}
			}
			if(tab.equals("2")) //
			{

						int size = 0;
						al.clear();
						if (request.getParameter("mSize") != null) size = Integer.parseInt(request.getParameter("mSize"));
						String itemRemoved = "";

						for (int i=1; i<=size; i++)
						{

							//System.out.println(" check en i = "+i+"    " +request.getParameter("check"+i));
							if (request.getParameter("check"+i) != null)
							{
								CommonDataObject cdo2 = new CommonDataObject();
								cdo2.setTableName("tbl_sal_evaluacion_muestra");
								cdo2.setWhereClause("evaluacion="+request.getParameter("code"));
								cdo2.addColValue("evaluacion",request.getParameter("code"));

								cdo2.addColValue("muestra",request.getParameter("muestra"+i));
								cdo2.addColValue("citologia",request.getParameter("citologia"+i));
								cdo2.addColValue("patologia",request.getParameter("patologia"+i));
								cdo2.addColValue("bacterias",request.getParameter("bacterias"+i));
								cdo2.addColValue("baar",request.getParameter("baar"+i));
								cdo2.addColValue("hongos",request.getParameter("hongos"+i));


								key = request.getParameter("key"+i);
								if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
								itemRemoved = key;
								else
								{
								 try
									{
										al.add(cdo2);
										iMuestra.put(key,cdo2);
									}
									catch(Exception e)
									{
										System.err.println(e.getMessage());
									}
								}//else
							}//check
						}//for


				if (baction.equalsIgnoreCase("Guardar"))
				{
					if (al.size() == 0)
					{
						CommonDataObject cdo1 = new CommonDataObject();

						cdo1.setTableName("tbl_sal_evaluacion_muestra");
						cdo1.setWhereClause("evaluacion="+request.getParameter("code"));
						al.add(cdo1);
					}

					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
					SQLMgr.insertList(al);
					ConMgr.clearAppCtx(null);
				}
			}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//  window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&fg=<%=fg%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&muestraLastLineNo=<%=muestraLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
