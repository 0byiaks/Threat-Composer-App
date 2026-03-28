import { FC, ReactNode, useEffect } from 'react';
import useLocalStorageState from 'use-local-storage-state';
import { v4 as uuidv4 } from 'uuid';
import { LOCAL_STORAGE_KEY_WORKSPACE_LIST_MIGRATION } from '../../configs/localStorageKeys';
import { useWorkspacesContext } from '../../contexts/WorkspacesContext/context';

export interface WorkspacesMigrationProps {
  children: ReactNode;
}

const WorkspacesMigration: FC<WorkspacesMigrationProps> = ({ children }) => {
  const { workspaceList, setWorkspaceList } = useWorkspacesContext();

  // This should mean: "migration attempted / not needed", not "block UI"
  const [migrationComplete, setMigrationComplete] = useLocalStorageState<boolean>(
    LOCAL_STORAGE_KEY_WORKSPACE_LIST_MIGRATION,
    {
      defaultValue: false,
    },
  );

  useEffect(() => {
    if (migrationComplete) return;

    // If there’s nothing to migrate yet, don’t block the app — just mark complete.
    if (!workspaceList || workspaceList.length === 0) {
      setMigrationComplete(true);
      return;
    }

    // New format already (object list)
    if (typeof workspaceList[0] !== 'string') {
      setMigrationComplete(true);
      return;
    }

    // Old format: string[]
    const newList = (workspaceList as unknown as string[]).map((name) => ({
      id: uuidv4(),
      name,
    }));

    setWorkspaceList(newList as any);
    setMigrationComplete(true);
  }, [migrationComplete, workspaceList, setWorkspaceList, setMigrationComplete]);

  // Always render the app; migration is a background concern.
  return <>{children}</>;
};

export default WorkspacesMigration;
