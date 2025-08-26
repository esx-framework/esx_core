// yoinked from https://github.com/overextended/ox_lib/blob/master/web/src/providers/errorBoundary.tsx
import { fetchNui } from '@/utils/fetchNui';
import { Component, ReactNode, ErrorInfo } from 'react';

class ErrorBoundary extends Component<{ children: ReactNode }, { hasError: boolean }> {
    constructor(props: { children: ReactNode }) {
        super(props);
        this.state = { hasError: false };
    }

    static getDerivedStateFromError(err: Error) {
        return { hasError: true };
    }

    componentDidCatch(error: Error, info: ErrorInfo) {
        console.error(error, info)
        this.setState({ hasError: false });
    }

    render() {
        return this.state.hasError ? null : this.props.children;
    }
}

export default ErrorBoundary;