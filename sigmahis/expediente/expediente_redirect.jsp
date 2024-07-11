<%
String seccion = request.getParameter("seccion");
String secDesc = request.getParameter("secDesc");
String toPage = "";
String sql = "";


if (seccion != null && !seccion.trim().equals(""))
{
	switch (Integer.parseInt(seccion))
	{   
		case 1: toPage = "../expediente/exp_enfermedad_actual.jsp?desc="+secDesc+" "; break;	
		case 2: toPage = "../expediente/exp_ant_personal.jsp?desc="+secDesc+" "; break;		
		case 3: toPage = "../expediente/exp_ant_gineco_obstetrico.jsp?desc="+secDesc+" "; break;
		case 4: toPage = "../expediente/exp_hospitalizacion_cirugias.jsp?desc="+secDesc+"&fg=H"; break;
		case 5: toPage = "../expediente/exp_medicamentos.jsp?desc="+secDesc+" "; break;
		case 6: toPage = "../expediente/exp_traumatismos_secuelas.jsp?desc="+secDesc+" "; break;
		case 7: toPage = "../expediente/exp_ant_familiar.jsp?desc="+secDesc+" "; break;
		case 8: toPage = "../expediente/exp_ant_prenatal.jsp?desc="+secDesc+" "; break;
		case 9: toPage = "../expediente/exp_ant_neonatal.jsp?desc="+secDesc+" "; break;
		case 10: toPage = "../expediente/exp_examen_fisico.jsp?desc="+secDesc+" "; break;
		case 11: toPage = "../expediente/exp_ant_alergico.jsp?desc="+secDesc+" "; break;
		case 12: toPage = "../expediente/exp_inmunizaciones.jsp?desc="+secDesc+" "; break;
		case 13: toPage = "../expediente/exp_crecimiento_desarrollo.jsp?desc="+secDesc+" "; break;
		case 14: toPage = "../expediente/exp_hist_obstetrica1.jsp?desc="+secDesc+" "; break;
		case 15: toPage = "../expediente/exp_hist_obstetrica2.jsp?desc="+secDesc+" "; break;
		case 16: toPage = "../expediente/exp_ant_transfusion.jsp?desc="+secDesc+" "; break;
		//case 17: toPage = "../expediente/exp_ant_traumaticos.jsp?desc="+secDesc+" "; break;
		case 18: toPage = "../expediente/exp_ant_epidemiologicos.jsp?desc="+secDesc+" "; break;
		case 19: toPage = "../expediente/exp_examenes.jsp?desc="+secDesc+"&fp=imagenologia"; break;
		case 20: toPage = "../expediente/exp_tratamientos.jsp?desc="+secDesc+" "; break;
		case 21: toPage = "../expediente/exp_datos_admision.jsp?desc="+secDesc+" "; break;
		case 22: toPage = "../expediente/exp_triage.jsp?desc="+secDesc+"&fg=TSV"; break;
		case 23: toPage = "../expediente/exp_procedimientos.jsp?desc="+secDesc+" "; break;
		case 24: toPage = "../expediente/exp_hoja_medicamento.jsp?desc="+secDesc+" "; break;
		case 25: toPage = "../expediente/exp_examenes.jsp?fp=laboratorio&desc="+secDesc+" "; break;
		case 26: toPage = "../expediente/exp_datos_salida.jsp?desc="+secDesc+" "; break;
		case 27: toPage = "../expediente/exp_ant_medicamentos.jsp?desc="+secDesc+" "; break;
		case 28: toPage = "../expediente/exp_solicitar_insumos.jsp?desc="+secDesc+" "; break;
		case 29: toPage = "../expediente/exp_devolver_insumos.jsp?desc="+secDesc+" "; break;
		case 30: toPage = "../expediente/exp_interconsulta_medica.jsp?desc="+secDesc+" "; break;//not used
		case 31: toPage = "../expediente/exp_notas_enfermeria.jsp?desc="+secDesc+"&fg=TD"; break;
		case 32: toPage = "../expediente/exp_balance_hidrico.jsp?desc="+secDesc+" "; break;
		case 33: toPage = "../expediente/exp_escala_norton.jsp?desc="+secDesc+"&fg=NO"; break;
		case 34: toPage = "../expediente/exp_hoja_diabetica.jsp?desc="+secDesc+" "; break;
		case 35: toPage = "../expediente/exp_inf_caso_policivo.jsp?desc="+secDesc+" "; break;
		case 36: toPage = "../expediente/exp_eval_ulceras_x_presion.jsp?desc="+secDesc+" "; break;
		case 37: toPage = "../expediente/exp_ordenes_dieteticas.jsp?desc="+secDesc+" "; break;
		case 38: toPage = "../expediente/exp_hoja_clinica.jsp?desc="+secDesc+" "; break;
		case 39: toPage = "../expediente/exp_hoja_defuncion.jsp?desc="+secDesc+" "; break;
		case 40: toPage = "../expediente/exp_escala_glasgow.jsp?desc="+secDesc+" "; break;
		case 41: toPage = "../expediente/exp_revision_preoperatoria.jsp?desc="+secDesc+" "; break;
		case 42: toPage = "../expediente/exp_recuperacion_anestesia.jsp?desc="+secDesc+" "; break;
		case 43: toPage = "../expediente/exp_ctrl_proc_invasivos.jsp?desc="+secDesc+" "; break;
		case 44: toPage = "../expediente/exp_lista_problemas.jsp?desc="+secDesc+" "; break;
		case 45: toPage = "../expediente/exp_resumen_clinico.jsp?desc="+secDesc+" "; break;
		case 46: toPage = "../expediente/exp_progreso_clinico.jsp?desc="+secDesc+" "; break;
		//case 47: toPage = "../expediente/exp_hospitalizacion_cirugias.jsp?fg=C"; break;
		case 47: toPage = "../expediente/exp_eval_preanestesica_new.jsp?desc="+secDesc+" "; break;
		//case 48: toPage = "../expediente/exp_hist_clinica.jsp"; break;
		case 49: toPage = "../expediente/exp_examen_fisico_rn.jsp?desc="+secDesc+" "; break;
		case 50: toPage = "../expediente/exp_interconsulta.jsp?desc="+secDesc+" "; break;
		case 51: toPage = "../expediente/exp_ekg.jsp?desc="+secDesc+" "; break;
		case 52: toPage = "../expediente/exp_prot_operatorio.jsp?desc="+secDesc+" "; break;
		case 53: toPage = "../expediente/exp_evaluacion_paciente.jsp?desc="+secDesc+"&fg=CR"; break;
		case 54: toPage = "../expediente/exp_evaluacion_paciente.jsp?desc="+secDesc+"&fg=EG"; break;
		case 55: toPage = "../expediente/exp_evaluacion_paciente.jsp?desc="+secDesc+"&fg=BR"; break;
		case 56: toPage = "../expediente/exp_evaluacion_paciente.jsp?desc="+secDesc+"&fg=CI"; break;
		case 57: toPage = "../expediente/exp_notas_enfermeria.jsp?desc="+secDesc+"&fg=HM"; break;
		case 58: toPage = "../expediente/exp_atencion_espiritual.jsp?desc="+secDesc+" "; break;
		case 59: toPage = "../expediente/exp_plan_salida.jsp?desc="+secDesc+" "; break;
		case 60: toPage = "../expediente/exp_parametros_hemodinamicos.jsp?desc="+secDesc+" "; break;
		case 61: toPage = "../expediente/exp_parametros_respiratorios.jsp?desc="+secDesc+" "; break;
		case 62: toPage = "../expediente/exp_nota_terapia.jsp?desc="+secDesc+" "; break;
		case 63: toPage = "../expediente/exp_enfermedades_operaciones.jsp?desc="+secDesc+"&fg=PEO"; break;
		case 64: toPage = "../expediente/exp_examen_fisico2.jsp?desc="+secDesc+" "; break;
		case 65: toPage = "../expediente/exp_reportes.jsp?desc="+secDesc+" "; break;
		case 66: toPage = "../expediente/exp_examen_fisico2.jsp?desc="+secDesc+"&tipo=E"; break;
		case 67: toPage = "../expediente/exp_notas_ingreso_enf.jsp?desc="+secDesc+"&fg=NIEN"; break;//notas enf. salas
		case 68: toPage = "../expediente/exp_notas_ingreso_enf.jsp?desc="+secDesc+"&fg=NIPE"; break;//notas pediatria
		case 69: toPage = "../expediente/exp_notas_ingreso_enf.jsp?desc="+secDesc+"&fg=NIPA"; break;//notas partos
		case 70: toPage = "../expediente/exp_notas_ingreso_enf.jsp?desc="+secDesc+"&fg=NINO"; break;//notas neonatologia
		case 71: toPage = "../expediente/exp_notas_egreso.jsp?desc="+secDesc+"&fg=NEEN"; break;
		case 72: toPage = "../expediente/exp_notas_egreso_parto.jsp?desc="+secDesc+"&fg=NEPA"; break;
		case 73: toPage = "../expediente/exp_notas_diarias_enf.jsp?desc="+secDesc+"&fg=NDNO"; break;
	    //case 74: toPage = "../expediente/exp_protocolo_universal.jsp?desc="+secDesc+"&fg=P1"; break;
		case 75: toPage = "../expediente/exp_ordenes_salida.jsp?desc="+secDesc+" "; break;
		case 76: toPage = "../expediente/exp_ordenes_varias.jsp?desc="+secDesc+" "; break;
		case 77: toPage = "../expediente/exp_triage.jsp?desc="+secDesc+"&fg=SV"; break;
		case 78: toPage = "../expediente/exp_examen_estudios.jsp?desc="+secDesc+"&fp=laboratorio"; break;
		case 79: toPage = "../expediente/exp_esquema_insulina.jsp?desc="+secDesc+" "; break;
		case 80: toPage = "../expediente/exp_escalas_dolor.jsp?desc="+secDesc+"&fg=WB"; break;
		case 81: toPage = "../expediente/exp_eval_nutricional.jsp?desc="+secDesc+" "; break;
		case 82: toPage = "../expediente/exp_escalas_dolor.jsp?desc="+secDesc+"&fg=CR"; break;
		case 83: toPage = "../expediente/exp_escalas_dolor.jsp?desc="+secDesc+"&fg=NI"; break;
		case 84: toPage = "../expediente/exp_escalas_dolor.jsp?desc="+secDesc+"&fg=AN"; break;
		case 85: toPage = "../expediente/exp_escalas_dolor.jsp?desc="+secDesc+"&fg=MO"; break;
		case 86: toPage = "../expediente/exp_medico_responsable.jsp?desc="+secDesc+" "; break;
		case 87: toPage = "../expediente/exp_notas_enfermeria.jsp?desc="+secDesc+"&fg=UR"; break;
		case 88: toPage = "../expediente/exp_diagnostico_salida.jsp?desc="+secDesc+" "; break;
		case 89: toPage = "../expediente/exp_diagnostico_ingreso.jsp?desc="+secDesc+" "; break;
		case 90: toPage = "../expediente/exp_notas_egreso_neo.jsp?desc="+secDesc+"&fg=NENO"; break;
		case 91: toPage = "../expediente/exp_escala_norton.jsp?desc="+secDesc+"&fg=BR"; break;
		case 92: toPage = "../expediente/exp_control_salida.jsp?desc="+secDesc+" "; break;
		case 93: toPage = "../expediente/exp_resultados_paciente.jsp?desc="+secDesc+" "; break;
		case 94: toPage = "../expediente/exp_horario_alimentacion.jsp?desc="+secDesc+" "; break;
		case 95: toPage = "../expediente/exp_historia_patologica.jsp?desc="+secDesc+" "; break;
		case 96: toPage = "../expediente/exp_escala_norton.jsp?desc="+secDesc+"&fg=SG"; break;
		case 97: toPage = "../expediente/exp_nutricion_parenteral.jsp?desc="+secDesc+"&fg=EA"; break;
		case 98: toPage = "../expediente/exp_nutricion_parenteral_neos.jsp?desc="+secDesc+"&fg=EN"; break;
		case 99: toPage = "../expediente/exp_evaluacion_risk.jsp?desc="+secDesc+"&fg=ENRS"; break;
		case 101: toPage = "../expediente/exp_escala_glasgow.jsp?desc="+secDesc+"&fg=N"; break;
		case 102: toPage = "../expediente/protocolo_universal_seguridad.jsp?desc="+secDesc+"&fg=PUSP"; break;	
		case 103: toPage = "../expediente/exp_tamizaje_nutricional.jsp?desc="+secDesc+"&fg=ENRS"; break;
		case 104: toPage = "../expediente/exp_terapia_eval.jsp?desc="+secDesc+"&fg=ETO"; break;
		case 105: toPage = "../expediente/exp_terapia_eval.jsp?desc="+secDesc+"&fg=ETF"; break;
		case 106: toPage = "../expediente/exp_nota_plan_terapia.jsp?desc="+secDesc+"&fg=NDP"; break;
		case 107: toPage = "../expediente/exp_nota_plan_terapia.jsp?desc="+secDesc+"&fg=PDT"; break;
		case 108: toPage = "../expediente/exp_nota_eval_enf_urg.jsp?desc="+secDesc+"&fg=NEEU"; break;
		default: toPage = ""; 		
	}
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" class="TextRow01">
<%
if (!toPage.equals(""))
{
%>
<jsp:forward page="<%=toPage%>"></jsp:forward>
<%
}
%>
</body>
</html>
