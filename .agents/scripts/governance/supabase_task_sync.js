/**
 * Supabase Task Sync script for AI Antigravity Agents
 * Allows agents to list, update, and create tasks directly in Supabase DB.
 * 
 * Usage:
 *   node .agents/scripts/supabase_task_sync.js list
 *   node .agents/scripts/supabase_task_sync.js update PRJ-ETX-001 --status DONE
 *   node .agents/scripts/supabase_task_sync.js add --id PRJ-NEW-001 --title "Titulo" --status DOING
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'https://iuwrcrwprdtugprdnswj.supabase.co';
const SUPABASE_KEY = process.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_LdhbXXpHTaMPPLedR0tLNQ_P4gGO2hD';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const args = process.argv.slice(2);
const command = args[0] || 'list';

async function main() {
  if (command === 'list') {
    const { data, error } = await supabase.from('projects').select('*').order('created_at', { ascending: false });
    if (error) {
      console.error('Error fetching projects:', error.message);
      process.exit(1);
    }
    console.log('=== PMO COMMAND CENTER PROJECTS ===');
    data.forEach(p => {
      console.log(`[${p.status}] ${p.id} - ${p.title} (F: ${p.functional_lead}, D: ${p.developer_lead})`);
    });
  } else if (command === 'update') {
    const id = args[1];
    const statusIdx = args.indexOf('--status');
    const status = statusIdx !== -1 ? args[statusIdx + 1] : null;

    if (!id || !status) {
      console.error('Usage: node supabase_task_sync.js update <ID> --status <STOPPER|DOING|BACKLOG|DONE>');
      process.exit(1);
    }

    const { error } = await supabase
      .from('projects')
      .update({ status: status.toUpperCase(), updated_at: new Date().toISOString() })
      .eq('id', id);

    if (error) {
      console.error('Error updating project:', error.message);
      process.exit(1);
    }

    // Log action
    await supabase.from('activity_logs').insert([{
      project_id: id,
      action: `Estado actualizado a ${status.toUpperCase()} por Agente AI`,
      actor: 'Antigravity Agent'
    }]);

    console.log(`✅ Proyecto ${id} actualizado con éxito a estado: ${status.toUpperCase()}`);
  } else if (command === 'add') {
    const idIdx = args.indexOf('--id');
    const titleIdx = args.indexOf('--title');
    const statusIdx = args.indexOf('--status');

    const id = idIdx !== -1 ? args[idIdx + 1] : `PRJ-${Date.now()}`;
    const title = titleIdx !== -1 ? args[titleIdx + 1] : 'Nuevo Proyecto';
    const status = statusIdx !== -1 ? args[statusIdx + 1] : 'BACKLOG';

    const { error } = await supabase.from('projects').insert([{
      id,
      title,
      status: status.toUpperCase(),
      type: id.startsWith('INC') ? 'INCIDENCE' : id.startsWith('SR') ? 'SERVICE_REQUEST' : 'PROJECT',
      functional_lead: 'Juan',
      developer_lead: 'Joan'
    }]);

    if (error) {
      console.error('Error adding project:', error.message);
      process.exit(1);
    }

    console.log(`✅ Proyecto ${id} ("${title}") creado con éxito.`);
  } else if (command === 'set-flag') {
    const id = args[1];
    const flagIdx = args.indexOf('--flag');
    const flagName = flagIdx !== -1 ? args[flagIdx + 1] : null;

    if (!id || !flagName) {
      console.error('Usage: node supabase_task_sync.js set-flag <ID> --flag <proposal_approved|fs_ts_created|test_script_created|user_manual_created|internal_test_done|uat_done|prod_transported>');
      process.exit(1);
    }

    const { data: project } = await supabase.from('projects').select('flags').eq('id', id).single();
    const updatedFlags = { ...(project?.flags || {}), [flagName]: true };

    const { error } = await supabase.from('projects').update({ flags: updatedFlags, updated_at: new Date().toISOString() }).eq('id', id);

    if (error) {
      console.error('Error updating flag:', error.message);
      process.exit(1);
    }

    await supabase.from('activity_logs').insert([{ project_id: id, action: `Hito completado: ${flagName}`, actor: 'Antigravity Agent' }]);
    console.log(`✅ Hito "${flagName}" marcado como COMPLETADO en ${id}`);
  }
}

main().catch(err => console.error(err));
