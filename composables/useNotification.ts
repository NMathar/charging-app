export const useNotification = () => {
  const snackbar = useState('snackbar', () => ({
    show: false,
    message: '',
    color: 'success',
    timeout: 3000,
  }));

  const showSuccess = (message: string, timeout = 3000) => {
    snackbar.value = {
      show: true,
      message,
      color: 'success',
      timeout,
    };
  };

  const showError = (message: string, timeout = 4000) => {
    snackbar.value = {
      show: true,
      message,
      color: 'error',
      timeout,
    };
  };

  const showInfo = (message: string, timeout = 3000) => {
    snackbar.value = {
      show: true,
      message,
      color: 'info',
      timeout,
    };
  };

  const hide = () => {
    snackbar.value.show = false;
  };

  return {
    snackbar,
    showSuccess,
    showError,
    showInfo,
    hide,
  };
};
